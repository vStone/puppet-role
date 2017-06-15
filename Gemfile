source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_from_env(env, default_location = [])
  if ENV[env]
    location = ENV[env]
    if location =~ %r{^(?<git_location>(?:git|https?)[:@][^#]*)#(?<git_branch>.*)}
      [{ git: git_location, branch: git_branch, require: false }]
    elsif location =~ %r{^file://(?<filename>.*)}
      ['>= 0', { path: File.expand_path(filename), require: false }]
    else
      [location, { require: false }]
    end
  else
    default_location
  end
end

group :development, :test do
  gem 'awesome_print'
  gem 'metadata-json-lint'
  gem 'puppet-lint', '~> 2'
  gem 'puppet-syntax'
  gem 'puppetlabs_spec_helper', '>= 1.2.1'
  gem 'rubocop', '~> 0.49.1'
  gem 'rubocop-rspec', '~> 1.15'
  gem 'rspec-puppet-facts'
end
group :doc do
  gem 'puppet-strings', '~> 1.0.0'
  gem 'rdoc'
  gem 'redcarpet'
end

gem 'facter', *location_from_env('FACTER_GEM_VERSION')
gem 'puppet', *location_from_env('PUPPET_GEM_VERSION')

