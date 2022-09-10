require 'spec_helper'

describe CarrierWave::Storage::AWSFile do
  let(:path)       { 'files/1/file.txt' }
  let(:file)       { double(:file, content_type: 'octet', path: '/file') }
  let(:bucket)     { double(:bucket, object: file) }
  let(:connection) { double(:connection, bucket: bucket) }

  let(:uploader) do
    double(:uploader,
           aws_bucket: 'example-com',
           aws_acl: :'public-read',
           aws_attributes: {},
           asset_host: nil,
           aws_signer: nil,
           aws_read_options: { encryption_key: 'abc' },
           aws_write_options: { encryption_key: 'def' })
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

    it 'is nil if the file has no extension' do
      aws_file.path = 'filetxt'

      expect(aws_file.extension).to be_nil
    end
  end

  describe '#read' do
    let(:s3_object) { instance_double('Aws::S3::Object') }

    it 'reads the retrieved body if called without block' do
      aws_file.file = s3_object

      expect(s3_object).to receive_message_chain('get.body.read')
      aws_file.read
    end

    it 'does not retrieve body if block given' do
      aws_file.file = s3_object
      block = proc {}

      expect(s3_object).to receive('get')
      expect(aws_file.read(&block)).to be_nil
    end
  end

  describe '#url' do
    it 'requests a public url if acl is public readable' do
      allow(uploader).to receive(:aws_acl) { :'public-read' }

      expect(file).to receive(:public_url)

      aws_file.url
    end

    it 'requests a public url if asset_host_public' do
      allow(uploader).to receive(:aws_acl) { :'authenticated-read' }
      allow(uploader).to receive(:asset_host_public) { true }

      expect(file).to receive(:public_url)

      aws_file.url
    end

    it 'requests an authenticated url if acl is not public readable' do
      allow(uploader).to receive(:aws_acl) { :private }
      allow(uploader).to receive(:aws_authenticated_url_expiration) { 60 }
      allow(uploader).to receive(:asset_host_public) { false }

      expect(file).to receive(:presigned_url).with(:get, { expires_in: 60 })

      aws_file.url
    end

    it 'requests an signed url if url signing is configured' do
      signature = 'Signature=QWERTZ&Key-Pair-Id=XYZ'

      cloudfront_signer = lambda do |unsigned_url, _|
        [unsigned_url, signature].join('?')
      end

      allow(uploader).to receive(:aws_signer) { cloudfront_signer }
      expect(file).to receive(:public_url) { 'http://example.com' }

      expect(aws_file.url).to eq "http://example.com?#{signature}"
    end

    it 'uses the asset_host and file path if asset_host is set' do
      allow(uploader).to receive(:aws_acl) { :'public-read' }
      allow(uploader).to receive(:asset_host) { 'http://example.com' }

      expect(aws_file.url).to eq('http://example.com/files/1/file.txt')
    end
  end

  describe '#store' do
    context 'when new_file is an AWSFile' do
      let(:new_file) do
        CarrierWave::Storage::AWSFile.new(uploader, connection, path)
      end

      it 'moves the object' do
        expect(new_file).to receive(:move_to).with(path)
        aws_file.store(new_file)
      end
    end

    context 'when new file if a SanitizedFile' do
      let(:new_file) do
        CarrierWave::SanitizedFile.new('spec/fixtures/image.png')
      end

      it 'uploads the file using with multipart support' do
        expect(file).to(receive(:upload_file)
                              .with(new_file.path, an_instance_of(Hash)))
        aws_file.store(new_file)
      end
    end
  end

  describe '#public_url' do
    it 'uri-encodes the path' do
      allow(uploader).to receive(:asset_host) { 'http://example.com' }
      aws_file.path = 'uploads/images/jekyll+and+hyde.txt'
      expect(aws_file.public_url).to eq 'http://example.com/uploads/images/jekyll%2Band%2Bhyde.txt'
    end
  end

  describe '#copy_to' do
    let(:new_s3_object) { instance_double('Aws::S3::Object') }

    it 'copies file to target path' do
      new_path = 'files/2/file.txt'
      expect(bucket).to receive(:object).with(new_path).and_return(new_s3_object)
      expect(file).to receive(:size).at_least(:once).and_return(1024)
      expect(file).to(
        receive(:copy_to).with(
          new_s3_object,
          aws_file.aws_options.copy_options(aws_file)
        )
      )
      aws_file.copy_to new_path
    end
  end
end
