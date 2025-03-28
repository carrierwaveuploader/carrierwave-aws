require 'spec_helper'

describe CarrierWave::Storage::AWSOptions do
  uploader_klass = Class.new do
    attr_accessor :aws_attributes, :aws_read_options, :aws_write_options

    def aws_acl
      'public-read'
    end

    def aws_authenticated_url_expiration
      '60'
    end
  end

  let(:uploader) { uploader_klass.new }
  let(:options) { described_class.new(uploader) }

  describe '#read_options' do
    it 'uses the uploader aws_read_options' do
      uploader.aws_read_options = { encryption_key: 'abc' }

      expect(options.read_options).to eq(uploader.aws_read_options)
    end

    it 'ensures that read_options are a hash' do
      uploader.aws_read_options = nil

      expect(options.read_options).to eq({})
    end
  end

  describe '#write_options' do
    let(:file) { CarrierWave::SanitizedFile.new('spec/fixtures/image.png') }

    it 'includes all access and file options' do
      uploader.aws_write_options = { encryption_key: 'def' }

      write_options = options.write_options(file)

      expect(write_options).to include(acl: 'public-read', content_type: 'image/png', encryption_key: 'def')
      expect(write_options[:body].path).to eq(file.path)
    end

    it 'works if aws_attributes is nil' do
      allow(uploader).to receive(:aws_attributes).and_return(nil)

      expect { options.write_options(file) }.not_to raise_error

      expect(uploader).to have_received(:aws_attributes)
    end

    it 'works if aws_attributes is a Proc' do
      allow(uploader).to receive(:aws_attributes).and_return(-> { { expires: (Date.today + 7).httpdate } })

      expect { options.write_options(file) }.not_to raise_error

      expect(uploader).to have_received(:aws_attributes)
    end

    it 'works if aws_write_options is nil' do
      allow(uploader).to receive(:aws_write_options).and_return(nil)

      expect { options.write_options(file) }.not_to raise_error

      expect(uploader).to have_received(:aws_write_options)
    end
  end

  describe '#expiration_options' do
    it 'extracts the expiration value' do
      expect(options.expiration_options).to eq(expires_in: uploader.aws_authenticated_url_expiration)
    end

    it 'allows expiration to be overridden' do
      expect(options.expiration_options(expires_in: 10)).to eq(expires_in: 10)
    end
  end
end
