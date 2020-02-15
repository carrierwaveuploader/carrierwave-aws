# frozen_string_literal: true

module CarrierWave
  module Support
    module UriFilename
      def self.filename(url)
        path = url.split('?').first

        CGI.unescape(path).gsub(%r{.*/(.*?$)}, '\1')
      end
    end
  end
end
