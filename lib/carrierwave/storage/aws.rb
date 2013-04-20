require 'aws/s3'

module CarrierWave
  module Storage
    class AWS < Abstract
      def self.connection_cache
        @connection_cache ||= {}
      end

      def store!(file)
        File.new(uploader, connection, uploader.store_path).tap do |aws_file|
          aws_file.store(file)
        end
      end

      def retrieve!(identifier)
        File.new(uploader, connection, uploader.store_path(identifier))
      end

      def connection
        @connection ||= begin
          credentials = uploader.aws_credentials
          self.class.connection_cache[credentials] ||= ::AWS::S3.new(credentials)
        end
      end

      class File
        attr_reader :uploader, :connection, :path

        def initialize(uploader, connection, path)
          @uploader   = uploader
          @connection = connection
          @path       = path
        end

        def to_file
          file
        end

        def attributes
          file.attributes
        end

        def content_type
          @content_type || file.content_type
        end

        def content_type=(new_content_type)
          @content_type = new_content_type
        end

        def delete
          file.delete
        end

        def extension
          path.split('.').last
        end

        def read
          file.read
        end

        def size
          file.content_length
        end

        def exists?
          !!file
        end

        def store(new_file)
          aws_file = new_file.to_file

          @file = bucket.objects[path].write(aws_file, {
            acl: uploader.aws_acl,
            content_type: new_file.content_type
          }.merge(uploader.aws_attributes || {}))

          aws_file.close unless aws_file.closed?

          true
        end

        def authenticated_url
          file.url_for(:read, expires: uploader.aws_authenticated_url_expiration).to_s
        end

        def public_url
          file.public_url.to_s
        end

        def url(options = {})
          if uploader.aws_acl != :public_read
            authenticated_url
          else
            public_url
          end
        end

        def filename(options = {})
          if file_url = url(options)
            file_url.gsub(/.*\/(.*?$)/, '\1')
          end
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
end
