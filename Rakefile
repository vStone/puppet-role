require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-lint/tasks/puppet-lint'
require 'rubocop/rake_task'
require 'puppet-strings/tasks/generate'

Rake::Task['rubocop'].clear
RuboCop::RakeTask.new(:rubocop) do |task|
  # Bug where rubocop searches paths recursivly. Ignoring this config.
  task.options = ['--config', '.rubocop.yml']
end

JENKINS_TASKS = %w[syntax lint rubocop spec metadata_lint].freeze

namespace :jenkins do
  task :all do
    base = ENV['BUNDLE_GEMFILE'].nil? ? 'rake' : "#{ENV['BUNDLE_BIN_PATH']} exec rake"
    failed_tasks = []
    JENKINS_TASKS.each do |target|
      # puts "Executing '#{base} #{target}'"
      failed_tasks << target unless system("#{base} #{target}")
    end
    unless failed_tasks.empty?
      warn "The following targets failed: #{failed_tasks.join(', ')}"
      exit(1)
    end
  end
end

desc 'Run all jenkins tasks'
task jenkins: ['jenkins:all']

Rake::Task['default'].clear
task default: %i[syntax lint rubocop validate]

PuppetLint.configuration.ignore_paths = ['spec/**/*.pp', 'pkg/**/*.pp', 'vendor/**/*.pp']
