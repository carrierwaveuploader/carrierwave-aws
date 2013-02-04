module CarrierWave
  module Storage
    class AWS < Abstract
      class << self
        def connection_cache
          @connection_cache ||= {}
        end
      end

      def store!(file)
      end

      def retrieve!(identifier)
      end

      def connection
      end

      class File
        attr_reader :path

        def initialize(uploader, base, path)
          @uploader, @base, @path = uploader, base, path
        end

        def attributes
          file.attributes
        end

        def authenticated_url
        end

        def content_type
        end

        def delete
        end

        def extension
        end

        def read
        end

        def size
        end

        def exists?
        end

        def store
        end

        def public_url
        end

        def url
        end

        def filename
        end

        def directory
        end

        def file
        end
      end
    end
  end
end
