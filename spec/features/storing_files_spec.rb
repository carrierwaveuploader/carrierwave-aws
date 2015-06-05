require 'spec_helper'

describe 'Storing Files', type: :feature do
  it 'uploads the file to the configured bucket' do
    uploader = Class.new(CarrierWave::Uploader::Base) do
      def filename; 'image.png'; end
    end

    image    = File.open('spec/fixtures/image.png', 'r')
    instance = uploader.new

    instance.store!(image)
    instance.retrieve_from_store!('image.png')

    expect(instance.file.size).to be_nonzero
    expect(image.size).to eq(instance.file.size)
    expect(instance.file.read).not_to be_nil

    image.close
    instance.file.delete
  end
end
