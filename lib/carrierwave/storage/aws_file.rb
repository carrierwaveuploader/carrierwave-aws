# frozen_string_literal: true

module CarrierWave
  module Storage
    class AWSFile
      attr_writer :file
      attr_accessor :uploader, :connection, :path, :aws_options

      delegate :content_type, :delete, :exists?, to: :file

      def initialize(uploader, connection, path)
        @uploader    = uploader
        @connection  = connection
        @path        = path
        @aws_options = AWSOptions.new(uploader)
      end

      def file
        @file ||= bucket.object(path)
      end

      def size
        file.size
      rescue Aws::S3::Errors::NotFound
        nil
      end

      alias to_file file

      def attributes
        file.data.to_h
      end

      def extension
        elements = path.split('.')
        elements.last if elements.size > 1
      end

      def filename(options = {})
        file_url = url(options)

        CarrierWave::Support::UriFilename.filename(file_url) if file_url
      end

      def read
        read_options = aws_options.read_options
        if block_given?
          file.get(read_options) { |chunk| yield chunk }
          nil
        else
          file.get(read_options).body.read
        end
      end

      def store(new_file)
        if new_file.is_a?(self.class)
          new_file.move_to(path)
        else
          file.upload_file(new_file.path, aws_options.write_options(new_file))
        end
      end

      def copy_to(new_path)
        bucket.object(new_path).copy_from(
          "#{bucket.name}/#{file.key}",
          aws_options.copy_options(self)
        )
      end

      def move_to(new_path)
        file.move_to(
          "#{bucket.name}/#{new_path}",
          aws_options.move_options(self)
        )
      end

      def signed_url(options = {})
        signer.call(public_url.dup, options)
      end

      def authenticated_url(options = {})
        file.presigned_url(:get, aws_options.expiration_options(options))
      end

      def public_url
        if uploader.asset_host
          "#{uploader.asset_host}/#{uri_path}"
        else
          file.public_url.to_s
        end
      end

      def url(options = {})
        if signer
          signed_url(options)
        elsif public?
          public_url
        else
          authenticated_url(options)
        end
      end

      private

      def bucket
        @bucket ||= connection.bucket(uploader.aws_bucket)
      end

      def signer
        uploader.aws_signer
      end

      def uri_path
        path.gsub(%r{[^/]+}) { |segment| Seahorse::Util.uri_escape(segment) }
      end

      def public?
        uploader.aws_acl.to_s == 'public-read' || uploader.asset_host_public
      end
    end
  end
end
