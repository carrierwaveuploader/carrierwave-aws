require 'spec_helper'

describe 'Copying Files', type: :feature do
  let(:image)    { File.open('spec/fixtures/image.png', 'r') }
  let(:original) { FeatureUploader.new }

  it 'copies an existing file to the specified path' do
    original.store!(image)
    original.retrieve_from_store!('image.png')

    original.file.copy_to('uploads/image2.png')

    copy = FeatureUploader.new
    copy.retrieve_from_store!('image2.png')

    original_attributes = original.file.attributes
    original_attributes.reject! { |key, _| key == :last_modified }

    copy_attributes = copy.file.attributes
    copy_attributes.reject! { |key, _| key == :last_modified }

    copy_acl_grants = copy.file.file.acl.grants
    original_acl_grants = original.file.file.acl.grants

    expect(copy_attributes).to eq(original_attributes)
    expect(copy_acl_grants).to eq(original_acl_grants)

    image.close
    original.file.delete
    copy.file.delete
  end
end
