require 'spec_helper'

describe 'Moving Files', type: :feature do
  let(:image)    { File.open('spec/fixtures/image.png', 'r') }
  let(:original) { FeatureUploader.new }

  it 'copies an existing file to the specified path' do
    original.store!(image)
    original.retrieve_from_store!('image.png')

    original_attributes = original.file.attributes
    original_acl_grants = original.file.file.acl.grants

    original.file.move_to('uploads/image2.png')

    move = FeatureUploader.new
    move.retrieve_from_store!('image2.png')

    copy_attributes = move.file.attributes
    copy_acl_grants = move.file.file.acl.grants

    expect(copy_attributes).to eq(original_attributes)
    expect(copy_acl_grants).to eq(original_acl_grants)
    expect(original.file).not_to exist

    image.close
    move.file.delete
  end
end
