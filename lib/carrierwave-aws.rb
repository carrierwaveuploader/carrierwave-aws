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
  add_config :sign_urls

  configure do |config|
    config.storage_engines[:aws] = 'CarrierWave::Storage::AWS'
  end

  def self.aws_acl
    @aws_acl
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

  def aws_acl
    @aws_acl || self.class.aws_acl
  end

  def aws_acl=(acl)
    @aws_acl = self.class.normalized_acl(acl)
  end
end
