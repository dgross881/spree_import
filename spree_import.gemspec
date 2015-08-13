$:.push File.expand_path("../lib", __FILE__)
# Maintain your gem's version:
require "spree_import/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "spree_import"
  s.version     = "3.0.1"
  s.authors     = ["dgross881"]
  s.email       = ["dgross881@gmail.com"]
  s.summary     = "Product Impoter for Spree"
  s.description = "A simple Plugin to Import Products on Spree"
  s.license     = "MIT"
  s.required_ruby_version = '>= 2.0.0'

 #  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.require_path = 'lib'
  s.requirements << 'none'
  
  s.add_dependency 'spree_core', '~> 3.0.0'
  s.add_dependency "rails", "~> 4.2.3"
  s.add_dependency 'delayed_job_active_record'

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.5'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 3.1'
  s.add_development_dependency 'sass-rails', '~> 4.0.2'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'poltergeist', '~> 1.6.0'
end
