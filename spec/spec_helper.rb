require 'carrierwave'
require 'carrierwave-aws'

def source_environment_file!
  return unless File.exist?('.env')

  File.readlines('.env').each do |line|
    key, value = line.split('=')
    ENV[key] = value.chomp
  end
end

FeatureUploader = Class.new(CarrierWave::Uploader::Base) do
  def filename
    'image.png'
  end
end

RSpec.configure do |config|
  source_environment_file!

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.filter_run_excluding type: :feature unless ENV.key?('S3_BUCKET_NAME')
  config.run_all_when_everything_filtered = true
  config.order = :random

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  Kernel.srand config.seed

  config.before(:all, type: :feature) do
    CarrierWave.configure do |cw_config|
      cw_config.storage       = :aws
      cw_config.cache_storage = :aws
      cw_config.aws_bucket    = ENV['S3_BUCKET_NAME']
      cw_config.aws_acl       = :'public-read'

      cw_config.aws_credentials = {
        access_key_id:     ENV['S3_ACCESS_KEY'],
        secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
        region:            ENV['AWS_REGION']
      }
    end
  end
end
