require 'spec_helper'

describe CarrierWave::Uploader::Base do
  it 'defines aws specific storage options' do
    expect(described_class).to respond_to(:aws_attributes)
  end

  it 'inserts aws as a known storage engine' do
    described_class.configure do |config|
      expect(config.storage_engines).to have_key(:aws)
    end
  end
end
