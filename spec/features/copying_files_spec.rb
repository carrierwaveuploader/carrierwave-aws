require 'spec_helper'

describe 'Copying Files', type: :feature do
  it 'copies an existing file to the specified path' do
    uploader = Class.new(CarrierWave::Uploader::Base) do
      def filename; 'image.png'; end
    end

    image    = File.open('spec/fixtures/image.png', 'r')
    original = uploader.new

    original.store!(image)
    original.retrieve_from_store!('image.png')

    original.file.copy_to('uploads/image2.png')

    copy = uploader.new
    copy.retrieve_from_store!('image2.png')

    original_attributes = original.file.attributes
    original_attributes.reject! { |k,v| k == :last_modified }

    copy_attributes = copy.file.attributes
    copy_attributes.reject! { |k,v| k == :last_modified }

    expect(copy_attributes).to eq(original_attributes)

    image.close
    original.file.delete
    copy.file.delete
  end
end

