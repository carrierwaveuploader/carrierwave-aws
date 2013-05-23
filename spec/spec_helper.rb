require 'rspec'
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
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus
  config.order = 'random'
  config.run_all_when_everything_filtered = true

  source_environment_file!
end
