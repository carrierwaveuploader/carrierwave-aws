# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carrierwave/aws/version'

Gem::Specification.new do |gem|
  gem.name          = 'carrierwave-aws'
  gem.version       = Carrierwave::AWS::VERSION
  gem.authors       = ['Parker Selbert']
  gem.email         = ['parker@sorentwo.com']
  gem.description   = %q{Use aws-sdk for S3 support in CarrierWave}
  gem.summary       = %q{A slimmer alternative to using Fog for S3 support in CarrierWave}
  gem.homepage      = 'https://github.com/sorentwo/carrierwave-aws'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'carrierwave', '>= 0.7'
  gem.add_dependency 'aws-sdk',     '>= 1.29'

  gem.add_development_dependency 'rspec', '~> 2.14'
end
