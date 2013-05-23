require 'spec_helper'

if ENV['S3_BUCKET_NAME']
  describe 'Storing Files' do
    before(:all) do
      CarrierWave.configure do |config|
        config.storage    = :aws
        config.aws_bucket = ENV['S3_BUCKET_NAME']
        config.aws_acl    = :public_read

        config.aws_credentials = {
          access_key_id:     ENV['S3_ACCESS_KEY'],
          secret_access_key: ENV['S3_SECRET_ACCESS_KEY']
        }
      end
    end

    it 'uploads the file to the configured bucket' do
      image    = File.open('spec/fixtures/image.png', 'r')
      uploader = Class.new(CarrierWave::Uploader::Base)
      instance = uploader.new

      expect {
        instance.store!(image)
        instance.retrieve_from_store!('image_file.png')
      }.to_not raise_error
    end
  end
end
