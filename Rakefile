# encoding: utf-8

begin
  require 'bundler/setup'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new
rescue LoadError
  task :rubocop do
    abort 'Rubocop is not available.'
  end
end

begin
  require 'yard'

  YARD::Rake::YardocTask.new
rescue LoadError
  task :yard do
    abort 'YARD is not available.'
  end
end

task :doc do
  Rake::Task['yard'].invoke
  YARD::CLI::Stats.run('--list-undoc')
end

task :rackup do
  system 'rackup'
end

task :guard do
  system 'guard'
end

task :default do
  Rake::Task['rackup'].invoke
end