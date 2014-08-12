require 'rspec/core/rake_task'
# RSpec::Core::RakeTask.new(:spec) do |spec|
#   spec.pattern = FileList['spec/**/*_spec.rb']
# end

RSpec::Core::RakeTask.new(:spec, :tag) do |t, task_args|
  t.rspec_opts = "--format documentation --color"
  t.rspec_opts += " --tag #{task_args[:tag]}" unless task_args[:tag].nil?
end

RSpec::Core::RakeTask.new(:specfile, :pattern) do |t, task_args|
  t.rspec_opts = "--format documentation --color"
  t.pattern = task_args[:pattern] unless task_args[:pattern].nil?
end

task :default => :spec
