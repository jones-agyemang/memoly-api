# frozen_string_literal: true

class FirstClassOauthApplication
  SETUP_CMD = "bin/rails setup:application"

  class UninitialisedApplication < StandardError; end

  def self.call
    Doorkeeper::Application.find_by!(name: ENV.fetch("OAUTH_APPLICATION_NAME"))
  rescue ActiveRecord::RecordNotFound
    msg = "First-class Oauth application is missing. Run `#{SETUP_CMD}`"
    raise UninitialisedApplication, msg
  end
end
