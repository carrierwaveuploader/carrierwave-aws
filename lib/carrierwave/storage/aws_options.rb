# frozen_string_literal: true

module CarrierWave
  module Storage
    class AWSOptions
      attr_reader :uploader

      def initialize(uploader)
        @uploader = uploader
      end

      def read_options
        aws_read_options
      end

      def write_options(new_file)
        {
          acl: uploader.aws_acl,
          body: new_file.to_file,
          content_type: new_file.content_type
        }.merge(aws_attributes).merge(aws_write_options)
      end

      def expiration_options(options = {})
        uploader_expiration = uploader.aws_authenticated_url_expiration

        { expires_in: uploader_expiration }.merge(options)
      end

      private

      def aws_attributes
        uploader.aws_attributes || {}
      end

      def aws_read_options
        uploader.aws_read_options || {}
      end

      def aws_write_options
        uploader.aws_write_options || {}
      end
    end
  end
end
