# frozen_string_literal: true

module CarrierWave
  module Storage
    class AWSOptions
      MULTIPART_TRESHOLD = 15 * 1024 * 1024

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

      def move_options(file)
        {
          acl: uploader.aws_acl,
          multipart_copy: file.size >= MULTIPART_TRESHOLD
        }.merge(aws_attributes).merge(aws_write_options)
      end
      alias copy_options move_options

      def expiration_options(options = {})
        uploader_expiration = uploader.aws_authenticated_url_expiration

        { expires_in: uploader_expiration }.merge(options)
      end

      private

      def aws_attributes
        attributes = uploader.aws_attributes
        return {} if attributes.nil?
        attributes.respond_to?(:call) ? attributes.call : attributes
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
