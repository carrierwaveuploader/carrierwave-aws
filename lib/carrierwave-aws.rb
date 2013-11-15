require 'carrierwave'
require 'carrierwave/aws/version'
require 'carrierwave/storage/aws'

class CarrierWave::Uploader::Base
  add_config :aws_attributes
  add_config :aws_authenticated_url_expiration
  add_config :aws_credentials
  add_config :aws_bucket
  add_config :aws_acl
  add_config :aws_read_options
  add_config :aws_write_options

  configure do |config|
    config.storage_engines[:aws] = 'CarrierWave::Storage::AWS'
  end
end
