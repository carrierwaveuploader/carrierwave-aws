require 'spec_helper'

describe 'Querying Files', type: :feature do
  it 'retrieves the attributes for a stored file' do
    uploader = Class.new(CarrierWave::Uploader::Base) do
      def filename; 'image.png'; end
    end

    image    = File.open('spec/fixtures/image.png', 'r')
    instance = uploader.new

    instance.store!(image)
    instance.retrieve_from_store!('image.png')

    expect(instance.file.attributes).to include(
      :metadata,
      :content_type,
      :etag,
      :accept_ranges,
      :last_modified,
      :content_length
    )

    image.close
    instance.file.delete
  end

  it 'checks if a remote file exists' do
    uploader = Class.new(CarrierWave::Uploader::Base) do
      def filename; 'image.png'; end
    end

    image    = File.open('spec/fixtures/image.png', 'r')
    instance = uploader.new

    instance.store!(image)
    instance.retrieve_from_store!('image.png')

    expect(instance.file.exists?).to be true

    instance.file.delete

    expect(instance.file.exists?).to be false

    image.close
  end
end
