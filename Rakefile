require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop) do |task|
    task.options = ['--format', ENV['RUBOCOP_FORMAT']] if ENV['RUBOCOP_FORMAT']
  end
rescue LoadError
  puts "RuboCop can't be run with gemfiles/*"
end

RSpec::Core::RakeTask.new(:spec)

task default: %i[rubocop spec]
