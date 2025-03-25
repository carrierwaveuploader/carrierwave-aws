require 'spec_helper'

describe CarrierWave::Storage::AWSFile do
  let(:path) { 'files/1/file.txt' }
  let(:file) { double(:file, content_type: 'octet', path: '/file') } # rubocop:disable RSpec/VerifiedDoubles
  let(:bucket) { double(:bucket, object: file) } # rubocop:disable RSpec/VerifiedDoubles
  let(:connection) { double(:connection, bucket: bucket) } # rubocop:disable RSpec/VerifiedDoubles
  let(:uploader) do
    double( # rubocop:disable RSpec/VerifiedDoubles
      :uploader,
      aws_bucket: 'example-com',
      aws_acl: :'public-read',
      aws_attributes: {},
      asset_host: nil,
      aws_signer: nil,
      aws_read_options: { encryption_key: 'abc' },
      aws_write_options: { encryption_key: 'def' }
    )
  end
  let(:aws_file) { described_class.new(uploader, connection, path) }

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
    let(:s3_object) { instance_double(Aws::S3::Object) }

    it 'reads the retrieved body if called without block' do
      aws_file.file = s3_object

      body_double = instance_double(StringIO)
      allow(body_double).to receive(:read)
      get_object_output = instance_double(Aws::S3::Types::GetObjectOutput, body: body_double)
      allow(s3_object).to receive(:get).and_return(get_object_output)

      aws_file.read

      expect(s3_object).to have_received(:get)
      expect(get_object_output).to have_received(:body)
      expect(body_double).to have_received(:read)
    end

    it 'does not retrieve body if block given' do
      aws_file.file = s3_object
      block = proc {}

      allow(s3_object).to receive(:get)

      expect(aws_file.read(&block)).to be_nil
      expect(s3_object).to have_received(:get)
    end
  end

  describe '#url' do
    it 'requests a public url if acl is public readable' do
      allow(uploader).to receive(:aws_acl).and_return(:'public-read')
      allow(file).to receive(:public_url)

      aws_file.url

      expect(file).to have_received(:public_url)
    end

    it 'requests a public url if asset_host_public' do
      allow(uploader).to receive_messages(aws_acl: :'authenticated-read', asset_host_public: true)
      allow(file).to receive(:public_url)

      aws_file.url

      expect(file).to have_received(:public_url)
    end

    it 'requests an authenticated url if acl is not public readable' do
      allow(uploader).to receive_messages(
        aws_acl: :private,
        aws_authenticated_url_expiration: 60,
        asset_host_public: false
      )
      allow(file).to receive(:presigned_url)

      aws_file.url

      expect(file).to have_received(:presigned_url).with(:get, expires_in: 60)
    end

    it 'requests a signed url if url signing is configured' do
      signature = 'Signature=QWERTZ&Key-Pair-Id=XYZ'

      cloudfront_signer = lambda do |unsigned_url, _|
        [unsigned_url, signature].join('?')
      end

      allow(uploader).to receive(:aws_signer).and_return(cloudfront_signer)
      allow(file).to receive(:public_url).and_return('http://example.com')

      expect(aws_file.url).to eq("http://example.com?#{signature}")
      expect(file).to have_received(:public_url)
    end

    it 'uses the asset_host and file path if asset_host is set' do
      allow(uploader).to receive_messages(aws_acl: :'public-read', asset_host: 'http://example.com')

      expect(aws_file.url).to eq('http://example.com/files/1/file.txt')
    end

    it 'accepts the asset_host given as a proc' do
      allow(uploader).to receive(:aws_acl).and_return(:'public-read')
      allow(uploader).to receive(:asset_host) do
        proc do |file|
          expect(file).to be_instance_of(described_class)
          'https://example.com'
        end
      end

      expect(aws_file.url).to eq('https://example.com/files/1/file.txt')
    end
  end

  describe '#store' do
    context 'when new_file is an AWSFile' do
      let(:new_file) { described_class.new(uploader, connection, path) }

      it 'moves the object' do
        allow(new_file).to receive(:move_to)

        aws_file.store(new_file)

        expect(new_file).to have_received(:move_to).with(path)
      end
    end

    context 'when new file is a SanitizedFile' do
      let(:new_file) { CarrierWave::SanitizedFile.new('spec/fixtures/image.png') }

      it 'uploads the file using with multipart support' do
        allow(file).to receive(:upload_file)

        aws_file.store(new_file)

        expect(file).to have_received(:upload_file).with(new_file.path, an_instance_of(Hash))
      end
    end
  end

  describe '#public_url' do
    it 'uri-encodes the path' do
      allow(uploader).to receive(:asset_host).and_return('http://example.com')
      aws_file.path = 'uploads/images/jekyll+and+hyde.txt'
      expect(aws_file.public_url).to eq('http://example.com/uploads/images/jekyll%2Band%2Bhyde.txt')
    end
  end

  describe '#copy_to' do
    let(:new_s3_object) { instance_double(Aws::S3::Object) }

    it 'copies file to target path' do
      new_path = 'files/2/file.txt'

      allow(bucket).to receive(:object).with(new_path).and_return(new_s3_object)
      allow(file).to receive(:size).and_return(1024)
      allow(file).to receive(:copy_to)

      aws_file.copy_to new_path

      expect(bucket).to have_received(:object).with(new_path)
      expect(file).to have_received(:copy_to).with(new_s3_object, aws_file.aws_options.copy_options(aws_file))
    end
  end
end
