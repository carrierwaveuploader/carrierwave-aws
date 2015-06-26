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

  describe '#to_file' do
    it 'returns the internal file instance' do
      file = Object.new
      aws_file.file = file

      expect(aws_file.to_file).to be(file)
    end
  end

  describe '#extension' do
    it 'extracts the file extension from the path' do
      aws_file.path = 'file.txt'

      expect(aws_file.extension).to eq('txt')
    end
  end

  # TODO: Stop stubbing. Include true and false cases for this.
  describe '#exists?' do
    it 'checks if the remote file object exists' do
      expect(file).to receive(:exists?).and_return(true)

      aws_file.exists?
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

end
