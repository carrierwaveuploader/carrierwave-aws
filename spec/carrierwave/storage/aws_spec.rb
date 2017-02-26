require 'spec_helper'

describe CarrierWave::Storage::AWS do
  let(:credentials) do
    { access_key_id: 'abc', secret_access_key: '123', region: 'us-east-1' }
  end

  let(:uploader) { double(:uploader, aws_credentials: credentials) }

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

    it 'caches connections by credentials' do
      new_storage = CarrierWave::Storage::AWS.new(uploader)

      expect(storage.connection).to be(new_storage.connection)
    end
  end
end
