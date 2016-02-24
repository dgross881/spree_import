require 'spree/testing_support/factories'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/preferences'

RSpec.configure do |config|
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
  config.include FactoryGirl::Syntax::Methods
  config.include Spree::TestingSupport::Preferences
  config.extend Spree::TestingSupport::AuthorizationHelpers::Request, type: :feature
end
