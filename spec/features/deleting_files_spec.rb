require 'spec_helper'

describe 'Deleting Files', type: :feature do
  let(:image)    { File.open('spec/fixtures/image.png', 'r') }
  let(:instance) { FeatureUploader.new }

  before do
    instance.aws_acl = 'public-read'
    instance.store!(image)
  end

  it 'deletes the image when assigned a `nil` value' do
  end
end
