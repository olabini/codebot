# frozen_string_literal: true

require 'bundler'
require 'bundler/gem_tasks'
require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task default: :check

begin
  Bundler.setup :development
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems.'
  exit e.status_code
end

task :check do
  Rake::Task[:spec].execute
  Rake::Task[:lint].execute
end

RSpec::Core::RakeTask.new :spec do |task|
  task.ruby_opts = '-E UTF-8'
end

RuboCop::RakeTask.new :lint
