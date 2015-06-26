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

    verify_existence(instance.file)
    verify_attributes(instance.file)
    verify_content_type(instance.file, 'image/png')
    verify_size(instance.file, image.size)
    verify_filename(instance.file, 'image.png')
    verify_reading(instance.file, image)

    image.close
    instance.file.delete
  end

  def verify_existence(file)
    expect(file.exists?).to be_truthy
  end

  def verify_attributes(file)
    expect(file.attributes).to have_key(:content_length)
    expect(file.attributes).to have_key(:content_type)
    expect(file.attributes).to have_key(:etag)
  end

  def verify_content_type(file, content_type)
    expect(file.content_type).to eq(content_type)
  end

  def verify_filename(file, name)
    expect(file.filename).to eq(name)
  end

  def verify_size(file, size)
    expect(file.size).to eq(size)
  end

  def verify_reading(file, image)
    expect(file.read).to eq(image.read)
    expect(file.read).to eq(file.read)
  end
end
