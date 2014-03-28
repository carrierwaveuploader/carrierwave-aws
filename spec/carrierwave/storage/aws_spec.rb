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
    it 'instantiates a new connection' do
      AWS::S3.should_receive(:new).with(credentials)

      storage.connection
    end

    it 'caches connections by credentials' do
      AWS::S3.should_receive(:new).with(credentials).and_return(double)

      storage.connection.should === storage.connection
    end
  end
end

describe CarrierWave::Storage::AWS::File do
  let(:objects)    { { 'files/1/file.txt' => file } }
  let(:bucket)     { double(:bucket, objects: objects) }
  let(:connection) { double(:connection, buckets: { 'example-com' => bucket }) }
  let(:file)       { double(:file, read: '0101010', content_type: 'content/type', path: '/file/path') }
  let(:uploader)   { double(:uploader, aws_bucket: 'example-com', aws_acl: :public_read, aws_attributes: {}, asset_host: nil, aws_read_options: { encryption_key: 'abc' }, aws_write_options: { encryption_key: 'def' }) }
  let(:path)       { 'files/1/file.txt' }

  subject(:aws_file) do
    CarrierWave::Storage::AWS::File.new(uploader, connection, path)
  end

  describe '#read' do
    it 'reads from the remote file object' do
      aws_file.read.should == '0101010'
    end
  end

  describe '#uploader_write_options' do
    it 'includes acl, content_type, file, aws_attributes, and aws_write_options' do
      aws_file.uploader_write_options(file).should == {
        acl: :public_read,
        content_type: 'content/type',
        file: '/file/path',
        encryption_key: 'def'
      }
    end

    it 'works if aws_attributes is nil' do
      uploader.stub(:aws_attributes) { nil }
      expect {
        aws_file.uploader_write_options(file)
      }.to_not raise_error
    end

    it 'works if aws_write_options is nil' do
      uploader.stub(:aws_write_options) { nil }
      expect {
        aws_file.uploader_write_options(file)
      }.to_not raise_error
    end
  end

  describe '#uploader_read_options' do
    it 'includes aws_read_options' do
      aws_file.uploader_read_options.should == { encryption_key: 'abc' }
    end

    it 'ensures that read options are a hash' do
      uploader.stub(:aws_read_options) { nil }
      aws_file.uploader_read_options.should == {}
    end
  end

  describe '#to_file' do
    it 'returns the internal file instance' do
      aws_file.to_file.should be(file)
    end
  end

  describe '#authenticated_url' do
    it 'requests a url for reading with the configured expiration' do
      uploader.stub(aws_authenticated_url_expiration: 60)

      file.should_receive(:url_for).with(:read, expires: 60)

      aws_file.authenticated_url
    end

    it 'requests a url for reading with custom options' do
      uploader.stub(aws_authenticated_url_expiration: 60)

      file.should_receive(:url_for).with(:read, hash_including(response_content_disposition: 'attachment'))

      aws_file.authenticated_url(response_content_disposition: 'attachment')
    end
  end

  describe '#url' do
    it 'requests a public url if acl is public readable' do
      uploader.stub(aws_acl: :public_read)
      file.should_receive(:public_url)

      aws_file.url
    end

    it 'requests an authenticated url if acl is not public readable' do
      uploader.stub(aws_acl: :private, aws_authenticated_url_expiration: 60)

      file.should_receive(:url_for)

      aws_file.url
    end

    it 'uses the asset_host and file path if asset_host is set' do
      uploader.stub(aws_acl: :public_read)
      uploader.stub(asset_host: 'http://example.com')

      aws_file.url.should eql 'http://example.com/files/1/file.txt'
    end
  end
end
