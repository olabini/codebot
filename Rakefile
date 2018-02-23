# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rubocop/rake_task'

task default: :check

begin
  Bundler.setup :check, :development
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems.'
  exit e.status_code
end

RuboCop::RakeTask.new(:check)
