source 'https://rubygems.org'

puppetversion = ENV['PUPPET_VERSION']

if puppetversion
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'puppet-lint',            '>= 0.3.2'
gem 'facter',                 '>= 1.7.0'

gem 'coveralls', :require => false

gem 'puppet-blacksmith',      '>= 3.1.1'

if RUBY_VERSION >= '2.0.0' and puppetversion < '3.8.7'
  gem 'syck'
end

### ADD USER GEMS HERE ###

