require 'spec_helper'

describe 'Storing Files', type: :feature do
  Uploader = Class.new(CarrierWave::Uploader::Base) do
    def filename; 'image.png'; end
  end

  let(:image)    { File.open('spec/fixtures/image.png', 'r') }
  let(:instance) { Uploader.new }

  it 'uploads the file to the configured bucket' do
    instance.store!(image)
    instance.retrieve_from_store!('image.png')

    verify_attributes(instance.file)
    verify_content_type(instance.file, 'image/png')

    expect(instance.file.size).to be_nonzero
    expect(image.size).to eq(instance.file.size)

    read = instance.file.read

    expect(read).not_to be_nil
    expect(read).to eq(instance.file.read)

    image.close
    instance.file.delete
  end

  def verify_attributes(file)
    expect(file.attributes).to have_key(:content_length)
    expect(file.attributes).to have_key(:content_type)
    expect(file.attributes).to have_key(:etag)
  end

  def verify_content_type(file, content_type)
    expect(file.content_type).to eq(content_type)
  end
end
