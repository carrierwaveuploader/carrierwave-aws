require 'spec_helper'

describe CarrierWave::Storage::AWS do
  let(:credentials) { { access_key_id: 'abc', secret_access_key: '123', region: 'us-east-1' } }
  let(:uploader)    { double(:uploader, aws_credentials: credentials) }

  subject(:storage) do
    CarrierWave::Storage::AWS.new(uploader)
  end

  before do
    CarrierWave::Storage::AWS.clear_connection_cache!
  end

  describe '#connection' do
    it 'instantiates a new connection with credentials' do
      expect(Aws::S3::Resource).to receive(:new).with(credentials)

      storage.connection
    end

    it 'instantiates a new connection without any credentials' do
      pending("aws-sdk v2 requires a region to be specified at instantiation time")
      allow(uploader).to receive(:aws_credentials) { nil }

      expect { storage.connection }.not_to raise_exception
    end

    it 'caches connections by credentials' do
      expect(storage.connection).to eq(storage.connection)
    end
  end
end
