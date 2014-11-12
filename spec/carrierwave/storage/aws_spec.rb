require 'spec_helper'

describe CarrierWave::Storage::AWS do
  let(:credentials) { { access_key_id: 'abc', secret_access_key: '123' } }
  let(:uploader)    { double(:uploader, aws_credentials: credentials) }

  subject(:storage) do
    CarrierWave::Storage::AWS.new(uploader)
  end

  before do
    CarrierWave::Storage::AWS.clear_connection_cache!
  end

  describe '#connection' do
    it 'instantiates a new connection with credentials' do
      expect(AWS::S3).to receive(:new).with(credentials)

      storage.connection
    end

    it 'instantiates a new connection without any credentials' do
      allow(uploader).to receive(:aws_credentials) { nil }

      expect { storage.connection }.not_to raise_exception
    end

    it 'caches connections by credentials' do
      expect(storage.connection).to eq(storage.connection)
    end
  end
end
