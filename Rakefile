require 'rspec/core'
require 'rspec/core/rake_task'
require "debugger"
# RSpec::Core::RakeTask.new(:spec) do |spec|
#   spec.pattern = FileList['spec/**/*_spec.rb']
# end

RSpec::Core::RakeTask.new(:spec, :tag) do |t, task_args|
  t.rspec_opts = "--format documentation --color"
  t.rspec_opts += " --tag #{task_args[:tag]}" unless task_args.to_hash.empty?
end

task :default => :spec

