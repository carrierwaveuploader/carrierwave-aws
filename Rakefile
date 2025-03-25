require 'bundler/setup'
require 'bundler/gem_tasks'

Bundler.setup

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.options = ['--format', ENV['RUBOCOP_FORMAT']] if ENV['RUBOCOP_FORMAT']
  end
rescue LoadError
  puts 'rubocop not loaded'
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  puts 'rspec not loaded'
end

task default: %i[rubocop spec]
