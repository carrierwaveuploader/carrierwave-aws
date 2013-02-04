require 'aws/s3'

module CarrierWave
  module Storage
    class AWS < Abstract
      def self.connection_cache
        @connection_cache ||= {}
      end

      def store!(file)
        File.new(uploader, self, uploader.store_path).tap do |aws_file|
          aws_file.store(file)
        end
      end

      def retrieve!(identifier)
        File.new(uploader, self, uploader.store_path(identifier))
      end

      def connection
        @connection ||= begin
          credentials = uploader.aws_credentials
          self.class.connection_cache[credentials] ||= ::AWS::S3.new(credentials)
        end
      end

      class File
        attr_reader :uploader, :base, :path

        def initialize(uploader, base, path)
          @uploader, @base, @path = uploader, base, path
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
          }.merge(uploader.aws_attributes))

          aws_file.close unless aws_file.closed?

          true
        end

        def authenticated_url
          file.url_for(:read, expires: uploader.aws_authenticated_url_expiration)
        end

        def public_url
          file.public_url
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

        def connection
          base.connection
        end

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
