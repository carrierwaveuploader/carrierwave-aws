module CarrierWave
  module Storage
    class AWSFile
      attr_writer :content_type
      attr_reader :uploader, :connection, :path, :aws_options

      def initialize(uploader, connection, path)
        @uploader    = uploader
        @connection  = connection
        @path        = path
        @aws_options = AWSOptions.new(uploader)
      end

      def attributes
        file.data.to_h
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
        file.get(aws_options.read_options).body.read
      end

      def size
        file.content_length
      end

      # TODO: What if this fails?
      def store(new_file)
        @file = file.put(aws_options.write_options(new_file))

        true
      end

      # TODO: This doesn't dup anything, why hide the actual file implementation?
      def to_file
        file
      end

      def url(options = {})
        if uploader.aws_acl.to_s != 'public-read'
          authenticated_url(options)
        else
          public_url
        end
      end

      def authenticated_url(options = {})
        file.presigned_url(:get, aws_options.expiration_options(options))
      end

      def public_url
        if uploader.asset_host
          "#{uploader.asset_host}/#{path}"
        else
          file.public_url.to_s
        end
      end

      def copy_to(new_path)
        bucket.object(new_path).copy_from(copy_source: "#{bucket.name}/#{file.key}")
      end

      private

      def bucket
        @bucket ||= connection.bucket(uploader.aws_bucket)
      end

      def file
        @file ||= bucket.object(path)
      end
    end
  end
end
