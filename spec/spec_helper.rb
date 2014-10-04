require 'carrierwave'
require 'carrierwave-aws'

def source_environment_file!
  return unless File.exists?('.env')

  File.readlines('.env').each do |line|
    values = line.split('=')
    ENV[values.first] = values.last.chomp
  end
end

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = :random

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  Kernel.srand config.seed

  source_environment_file!
end
