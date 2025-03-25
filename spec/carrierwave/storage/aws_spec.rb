require 'spec_helper'

describe CarrierWave::Storage::AWS do
  let(:credentials) { { access_key_id: 'abc', secret_access_key: '123', region: 'us-east-1' } }
  let(:uploader) { instance_double(CarrierWave::Uploader::Base, aws_credentials: credentials) }
  let(:storage) { described_class.new(uploader) }

  before { described_class.clear_connection_cache! }

  describe '#connection' do
    let(:s3_resource_instance) { instance_double(Aws::S3::Resource) }

    it 'instantiates a new connection with credentials' do
      allow(Aws::S3::Resource).to receive(:new).and_return(s3_resource_instance)

      expect(storage.connection).to eq(s3_resource_instance)
      expect(Aws::S3::Resource).to have_received(:new).with(credentials)
    end

    it 'caches connections by credentials' do
      new_storage = described_class.new(uploader)

      expect(storage.connection).to be(new_storage.connection)
    end
  end
end
