require 'carrierwave'
require 'carrierwave-aws'

def source_environment_file!
  return unless File.exists?('.env')

  File.readlines('.env').each do |line|
    values = line.split('=')
    ENV[values.first] = values.last.chomp
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
    CarrierWave.configure do |config|
      config.storage    = :aws
      config.aws_bucket = ENV['S3_BUCKET_NAME']
      config.aws_acl    = :public_read

      config.aws_credentials = {
        access_key_id:     ENV['S3_ACCESS_KEY'],
        secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
        region:            ENV['S3_REGION']
      }
    end
  end
end
