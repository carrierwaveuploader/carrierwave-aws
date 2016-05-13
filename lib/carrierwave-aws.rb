# frozen_string_literal: true

require 'carrierwave'
require 'carrierwave/aws/version'
require 'carrierwave/storage/aws'
require 'carrierwave/storage/aws_file'
require 'carrierwave/storage/aws_options'
require 'carrierwave/support/uri_filename'

module CarrierWave
  module Uploader
    class Base
      ACCEPTED_ACL = %w[
        private
        public-read
        public-read-write
        authenticated-read
        bucket-owner-read
        bucket-owner-full-control
      ].freeze

      ConfigurationError = Class.new(StandardError)

      add_config :aws_attributes
      add_config :aws_authenticated_url_expiration
      add_config :aws_credentials
      add_config :aws_bucket
      add_config :aws_read_options
      add_config :aws_write_options
      add_config :aws_acl
      add_config :aws_signer

      configure do |config|
        config.storage_engines[:aws] = 'CarrierWave::Storage::AWS'
      end

      def self.aws_acl=(acl)
        @aws_acl = normalized_acl(acl)
      end

      def self.normalized_acl(acl)
        normalized = acl.to_s.downcase.sub('_', '-')

        unless ACCEPTED_ACL.include?(normalized)
          raise ConfigurationError, "Invalid ACL option: #{normalized}"
        end

        normalized
      end

      def self.aws_signer(value = nil)
        self.aws_signer = value if value

        if instance_variable_defined?('@aws_signer')
          @aws_signer
        elsif superclass.respond_to? :aws_signer
          superclass.aws_signer
        end
      end

      def self.aws_signer=(signer)
        @aws_signer = validated_signer(signer)
      end

      def self.validated_signer(signer)
        unless signer.nil? || signer.instance_of?(Proc) && signer.arity == 2
          raise ConfigurationError,
                'Invalid signer option. Signer proc has to respond to' \
                '`.call(unsigned_url, options)`'
        end

        signer
      end

      def aws_acl=(acl)
        @aws_acl = self.class.normalized_acl(acl)
      end

      def aws_signer
        if instance_variable_defined?('@aws_signer')
          @aws_signer
        else
          self.class.aws_signer
        end
      end
    end
  end
end
