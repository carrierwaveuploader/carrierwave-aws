require 'spec_helper'

describe CarrierWave::Storage::AWSFile do
  let(:path)       { 'files/1/file.txt' }
  let(:file)       { double(:file, content_type: 'content/type', path: '/file/path') }
  let(:bucket)     { double(:bucket, object: file) }
  let(:connection) { double(:connection, bucket: bucket) }

  let(:uploader) do
    double(:uploader,
      aws_bucket: 'example-com',
      aws_acl: :'public-read',
      aws_attributes: {},
      asset_host: nil,
      aws_read_options: { encryption_key: 'abc' },
      aws_write_options: { encryption_key: 'def' }
    )
  end

  subject(:aws_file) do
    CarrierWave::Storage::AWSFile.new(uploader, connection, path)
  end

  describe '#exists?' do
    it 'checks if the remote file object exists' do
      expect(file).to receive(:exists?).and_return(true)

      aws_file.exists?
    end
  end

  describe '#uploader_write_options' do
    let(:stub_file) { CarrierWave::SanitizedFile.new('spec/fixtures/image.png') }
    it 'includes acl, content_type, body (file), aws_attributes, and aws_write_options' do
      uploader_write_options = aws_file.uploader_write_options(stub_file)

      expect(uploader_write_options).to include(
        acl:            :'public-read',
        content_type:   'image/png',
        encryption_key: 'def'
      )
      expect(uploader_write_options[:body].path).to eq(stub_file.path)
    end

    it 'works if aws_attributes is nil' do
      allow(uploader).to receive(:aws_attributes) { nil }

      expect {
        aws_file.uploader_write_options(stub_file)
      }.to_not raise_error
    end

    it 'works if aws_write_options is nil' do
      allow(uploader).to receive(:aws_write_options) { nil }

      expect {
        aws_file.uploader_write_options(stub_file)
      }.to_not raise_error
    end
  end

  describe '#uploader_read_options' do
    it 'includes aws_read_options' do
      expect(aws_file.uploader_read_options).to eq(encryption_key: 'abc')
    end

    it 'ensures that read options are a hash' do
      allow(uploader).to receive(:aws_read_options) { nil }

      expect(aws_file.uploader_read_options).to eq({})
    end
  end

  describe '#to_file' do
    it 'returns the internal file instance' do
      expect(aws_file.to_file).to be(file)
    end
  end

  describe '#authenticated_url' do
    it 'requests a url for reading with the configured expiration' do
      allow(uploader).to receive(:aws_authenticated_url_expiration) { 60 }

      expect(file).to receive(:presigned_url).with(:get, { expires_in: 60 })

      aws_file.authenticated_url
    end

    it 'requests a url for reading with custom options' do
      allow(uploader).to receive(:aws_authenticated_url_expiration) { 60 }

      expect(file).to receive(:presigned_url).with(:get, hash_including(response_content_disposition: 'attachment'))

      aws_file.authenticated_url(response_content_disposition: 'attachment')
    end
  end

  describe '#url' do
    it 'requests a public url if acl is public readable' do
      allow(uploader).to receive(:aws_acl) { :'public-read' }

      expect(file).to receive(:public_url)

      aws_file.url
    end

    it 'requests an authenticated url if acl is not public readable' do
      allow(uploader).to receive(:aws_acl) { :private }
      allow(uploader).to receive(:aws_authenticated_url_expiration) { 60 }

      expect(file).to receive(:presigned_url).with(:get, { expires_in: 60 })

      aws_file.url
    end

    it 'uses the asset_host and file path if asset_host is set' do
      allow(uploader).to receive(:aws_acl) { :'public-read' }
      allow(uploader).to receive(:asset_host) { 'http://example.com' }

      expect(aws_file.url).to eq('http://example.com/files/1/file.txt')
    end
  end

  describe '#filename' do
    it 'returns the filename from the url' do
      expect(aws_file).to receive(:url).and_return('http://example.com/files/1/file%201.txt?foo=bar/baz.txt')

      expect(aws_file.filename).to eq('file 1.txt')
    end
  end
end
