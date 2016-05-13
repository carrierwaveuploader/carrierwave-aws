require 'spec_helper'

describe CarrierWave::Support::UriFilename do
  UriFilename = CarrierWave::Support::UriFilename

  describe '.filename' do
    it 'extracts a decoded filename from file uri' do
      samples = {
        'http://ex.com/file.txt' => 'file.txt',
        'http://ex.com/files/1/file%201.txt?foo=bar/baz.txt' => 'file 1.txt'
      }

      samples.each do |uri, name|
        expect(UriFilename.filename(uri)).to eq(name)
      end
    end
  end
end
