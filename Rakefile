require "bundler/gem_tasks"
require "rspec/core/rake_task"

require "logstash/devutils/rake"

RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--color', '--format', 'documentation']
end

task :default => :spec
