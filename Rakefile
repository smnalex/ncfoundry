require "rake"
require "rspec/core/rake_task"
require 'bundler/gem_tasks'
require 'rake/version_task'

Rake::VersionTask.new
Dir.glob("lib/tasks/**/*").sort.each { |ext| load(ext) }

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "cfoundry/version"


RSpec::Core::RakeTask.new(:spec)
task :default => :spec
