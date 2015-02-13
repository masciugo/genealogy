require 'rspec/core'
require 'rspec/core/rake_task'

desc "Run all specs in spec directory (excluding plugin specs) or the ones tagged by provided tag"
RSpec::Core::RakeTask.new(:spec, :tag, :seed) do |t, task_args|
  t.rspec_opts = ''
  t.rspec_opts += " --tag #{task_args[:tag]}" unless task_args[:tag].to_s.empty?
  t.rspec_opts += " --seed #{task_args[:seed]}" unless task_args[:seed].to_s.empty?
end

desc "Run specfiles specified by pattern with optional seed"
RSpec::Core::RakeTask.new(:specfile, :pattern, :seed) do |t, task_args|
  t.pattern = task_args[:pattern] unless task_args[:pattern].nil?
  t.rspec_opts = ''
  t.rspec_opts += " --seed #{task_args[:seed]}" unless task_args[:seed].to_s.empty?
end

task :default => :spec

require "github/markup"
require "redcarpet"
require "yard"
require "yard/rake/yardoc_task"

YARD::Rake::YardocTask.new do |t|
  OTHER_PATHS = %w()
  t.files = ['lib/**/*.rb', OTHER_PATHS]
  t.options = %w(--markup-provider=redcarpet --markup=markdown --main=README.md)
end