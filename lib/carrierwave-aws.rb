require 'carrierwave'
require 'carrierwave/aws/version'
require 'carrierwave/storage/aws'
require 'carrierwave/storage/aws_file'
require 'carrierwave/storage/aws_options'
require 'carrierwave/support/uri_filename'

class CarrierWave::Uploader::Base
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

  configure do |config|
    config.storage_engines[:aws] = 'CarrierWave::Storage::AWS'
  end

  def self.aws_acl=(acl)
    @aws_acl = normalized_acl(acl)
  end

  def self.normalized_acl(acl)
    normalized = acl.to_s.downcase.sub('_', '-')

    unless ACCEPTED_ACL.include?(normalized)
      raise ConfigurationError.new("Invalid ACL option: #{normalized}")
    end

    normalized
  end

  def self.aws_signer
    @aws_signer
  end

  def self.aws_signer=(signer)
    @aws_signer = validated_signer(signer)
  end

  def self.validated_signer(signer)
    unless signer.instance_of?(Proc) && signer.arity == 2
      raise ConfigurationError.new("Invalid signer option. Signer proc has to respond to '.call(unsigned_url, options)'")
    end

    signer
  end

  def aws_acl=(acl)
    @aws_acl = self.class.normalized_acl(acl)
  end

  def aws_signer
    @aws_signer || self.class.aws_signer
  end

  def aws_signer=(signer)
    @aws_signer = self.class.validated_signer(signer)
  end
end
