require 'spec_helper'

describe CarrierWave::Uploader::Base do
  let(:uploader) do
    Class.new(CarrierWave::Uploader::Base)
  end

  let(:derived_uploader) do
    Class.new(uploader)
  end

  it 'inserts aws as a known storage engine' do
    uploader.configure do |config|
      expect(config.storage_engines).to have_key(:aws)
    end
  end

  it 'defines aws specific storage options' do
    expect(uploader).to respond_to(:aws_attributes)
  end

  describe '#aws_acl' do
    it 'allows known acess control values' do
      expect do
        uploader.aws_acl = 'private'
        uploader.aws_acl = 'public-read'
        uploader.aws_acl = 'authenticated-read'
      end.not_to raise_exception
    end

    it 'does not allow unknown control values' do
      expect do
        uploader.aws_acl = 'everybody'
      end.to raise_exception(CarrierWave::Uploader::Base::ConfigurationError)
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

      expect(derived_uploader.aws_acl).to eq('private')
      expect(instance.aws_acl).to eq('private')
    end

    it 'can be overridden on a class level' do
      uploader.aws_acl = 'public-read'
      derived_uploader.aws_acl = 'private'

      base = uploader.new
      expect(base.aws_acl).to eq('public-read')

      instance = derived_uploader.new
      expect(instance.aws_acl).to eq('private')
    end

    it 'can be set with the configure block' do
      uploader.configure do |config|
        config.aws_acl = 'public-read'
      end

      expect(uploader.aws_acl).to eq('public-read')
    end
  end

  describe '#aws_signer' do
    let(:signer_proc) { ->(_unsigned, _options) {} }
    let(:other_signer) { ->(_unsigned, _options) {} }

    it 'allows proper signer object' do
      expect { uploader.aws_signer = signer_proc }.not_to raise_exception
    end

    it 'does not allow signer with unknown api' do
      signer_proc = ->(_unsigned) {}

      expect { uploader.aws_signer = signer_proc }
        .to raise_exception(CarrierWave::Uploader::Base::ConfigurationError)
    end

    it 'can be overridden on an instance level' do
      instance = uploader.new

      uploader.aws_signer = signer_proc
      instance.aws_signer = other_signer

      expect(uploader.aws_signer).to eql(signer_proc)
      expect(instance.aws_signer).to eql(other_signer)
    end

    it 'can be overridden on a class level' do
      uploader.aws_signer = signer_proc
      derived_uploader.aws_signer = other_signer

      base = uploader.new
      expect(base.aws_signer).to eq(signer_proc)

      instance = derived_uploader.new
      expect(instance.aws_signer).to eql(other_signer)
    end

    it 'can be looked up from superclass' do
      uploader.aws_signer = signer_proc
      instance = derived_uploader.new

      expect(derived_uploader.aws_signer).to eq(signer_proc)
      expect(instance.aws_signer).to eql(signer_proc)
    end

    it 'can be set with the configure block' do
      uploader.configure do |config|
        config.aws_signer = signer_proc
      end

      expect(uploader.aws_signer).to eql(signer_proc)
    end

    it 'can be set when passed as argument to the class getter method' do
      uploader.aws_signer signer_proc

      expect(uploader.aws_signer).to eql(signer_proc)
    end
  end
end
