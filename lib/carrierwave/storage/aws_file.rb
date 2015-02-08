module CarrierWave
  module Storage
    class AWSFile
      attr_writer :content_type
      attr_reader :uploader, :connection, :path

      def initialize(uploader, connection, path)
        @uploader   = uploader
        @connection = connection
        @path       = path
      end

      def attributes
        file.head.data
      end

      def content_type
        @content_type || file.content_type
      end

      def delete
        file.delete
      end

      def extension
        path.split('.').last
      end

      def exists?
        file.exists?
      end

      def filename(options = {})
        if file_url = url(options)
          URI.decode(file_url.split('?').first).gsub(/.*\/(.*?$)/, '\1')
        end
      end

      def read
        file.read(uploader_read_options)
      end

      def size
        file.content_length
      end

      def store(new_file)
        @file = bucket.objects[path].write(uploader_write_options(new_file))

        true
      end

      def to_file
        file
      end

      def url(options = {})
        if uploader.sign_cloudfront
          unless defined?(::AWS::CF::Signer)
            raise "You must include the cloudfront-signer gem and configure it properly to use signed cloudfront urls"
          end
          ::AWS::CF::Signer.sign_url([public_url, options.to_query].join '?')
        elsif uploader.aws_acl != :public_read
          authenticated_url(options)
        else
          public_url
        end
      end

      def authenticated_url(options = {})
        file.url_for(:read, { expires: uploader.aws_authenticated_url_expiration }.merge(options)).to_s
      end

      def public_url
        if uploader.asset_host
          "#{uploader.asset_host}/#{path}"
        else
          file.public_url.to_s
        end
      end

      def copy_to(new_path)
        file.copy_to(bucket.objects[new_path], uploader_copy_options)
      end

      def uploader_read_options
        uploader.aws_read_options || {}
      end

      def uploader_write_options(new_file)
        aws_attributes    = uploader.aws_attributes    || {}
        aws_write_options = uploader.aws_write_options || {}

        { acl:          uploader.aws_acl,
          content_type: new_file.content_type,
          file:         new_file.path
        }.merge(aws_attributes).merge(aws_write_options)
      end

      def uploader_copy_options
        aws_write_options = uploader.aws_write_options || {}

        storage_options = aws_write_options.select do |key,_|
          [:reduced_redundancy, :storage_class, :server_side_encryption].include?(key)
        end

        { acl: uploader.aws_acl }.merge(storage_options)
      end

      private

      def bucket
        @bucket ||= connection.buckets[uploader.aws_bucket]
      end

      def file
        @file ||= bucket.objects[path]
      end
    end
  end
end
