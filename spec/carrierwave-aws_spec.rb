require 'spec_helper'

describe CarrierWave::Uploader::Base do
  let(:uploader) { CarrierWave::Uploader::Base }

  it 'inserts aws as a known storage engine' do
    uploader.configure do |config|
      expect(config.storage_engines).to have_key(:aws)
    end
  end

  it 'defines aws specific storage options' do
    expect(uploader).to respond_to(:aws_attributes)
  end

  describe '#aws_acl' do
    let(:derived_uploader) { FeatureUploader }

    it 'allows known acess control values' do
      expect {
        uploader.aws_acl = 'private'
        uploader.aws_acl = 'public-read'
        uploader.aws_acl = 'authenticated-read'
      }.not_to raise_exception
    end

    it 'does not allow unknown control values' do
      expect {
        uploader.aws_acl = 'everybody'
      }.to raise_exception
    end

    it 'normalizes the set value' do
      uploader.aws_acl = :'public-read'
      expect(uploader.aws_acl).to eq('public-read')

      uploader.aws_acl = 'PUBLIC_READ'
      expect(uploader.aws_acl).to eq('public-read')
    end

    it 'can be overridden on an instance level' do
      instance = uploader.new

      uploader.aws_acl = 'private'
      instance.aws_acl = 'public-read'

      expect(uploader.aws_acl).to eq('private')
      expect(instance.aws_acl).to eq('public-read')
    end

    it 'can be looked up from superclass' do
      uploader.aws_acl = 'private'
      instance = derived_uploader.new

      expect(derived_uploader.aws_acl).to eq 'private'
      expect(instance.aws_acl).to eq 'private'
    end
  end
end
