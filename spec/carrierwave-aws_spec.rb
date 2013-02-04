require 'spec_helper'

describe CarrierWave::Uploader::Base do
  it 'defines aws specific storage options' do
    described_class.should respond_to(:aws_attributes)
  end

  it 'inserts aws as a known storage engine' do
    described_class.configure do |config|
      config.storage_engines.should have_key(:aws)
    end
  end
end
