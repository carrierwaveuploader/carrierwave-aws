module CarrierWave
  module Support
    module UriFilename
      def self.filename(url)
        path = url.split('?').first

        URI.decode(path).gsub(/.*\/(.*?$)/, '\1')
      end
    end
  end
end
