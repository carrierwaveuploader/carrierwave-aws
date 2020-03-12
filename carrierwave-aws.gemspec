# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'carrierwave/aws/version'

Gem::Specification.new do |gem|
  gem.name = 'carrierwave-aws'
  gem.version = Carrierwave::AWS::VERSION
  gem.authors = ['Parker Selbert']
  gem.email = ['parker@sorentwo.com']
  gem.homepage = 'https://github.com/sorentwo/carrierwave-aws'
  gem.description = 'Use aws-sdk for S3 support in CarrierWave'
  gem.summary = 'Native aws-sdk support for S3 in CarrierWave'
  gem.license = 'MIT'

  gem.files = `git ls-files -z lib spec`.split("\x0")
  gem.test_files = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'carrierwave', '>= 0.7', '< 2.2'
  gem.add_dependency 'aws-sdk-s3', '~> 1.0'

  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rspec', '~> 3.6'
end
