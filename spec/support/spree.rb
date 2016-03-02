require 'spree/testing_support/factories'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/capybara_ext'
require 'spree/testing_support/preferences'
require 'rspec/active_model/mocks'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Spree::TestingSupport::Preferences
  config.extend Spree::TestingSupport::AuthorizationHelpers::Request, type: :feature
end
