lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'carrierwave/aws/version'

Gem::Specification.new do |spec|
  spec.name = 'carrierwave-aws'
  spec.version = Carrierwave::AWS::VERSION
  spec.authors = ['Parker Selbert']
  spec.email = ['parker@sorentwo.com']
  spec.description = 'Use aws-sdk for S3 support in CarrierWave'
  spec.summary = 'Native aws-sdk support for S3 in CarrierWave'
  spec.license = 'MIT'

  github_root_uri = 'https://github.com/carrierwaveuploader/carrierwave-aws'
  spec.homepage = "#{github_root_uri}/tree/v#{spec.version}"
  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{github_root_uri}/blob/v#{spec.version}/CHANGELOG.md",
    'bug_tracker_uri' => "#{github_root_uri}/issues",
    'documentation_uri' => "https://rubydoc.info/gems/#{spec.name}/#{spec.version}"
  }

  spec.files = `git ls-files -z lib spec`.split("\x0")
  spec.test_files = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_dependency 'aws-sdk-s3', '~> 1.0'
  spec.add_dependency 'carrierwave', '>= 2.0', '< 4'

  spec.add_development_dependency 'nokogiri'
  spec.add_development_dependency 'rspec', '~> 3.6'
end
