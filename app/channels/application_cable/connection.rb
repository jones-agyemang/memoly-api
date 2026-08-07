module ApplicationCable
  class InvalidAuthenticationMeansError < StandardError; end

  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      err_msg = "Subscriber-provided `user_id` cannot be accepted"
      raise InvalidAuthenticationMeansError, err_msg if cable_token.strip.empty? && request.params.key?(:user_id)

      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      user = User.find_signed(cable_token, purpose: :action_cable) if cable_token.present?

      user || reject_unauthorized_connection
    end

    def cable_token
      request.params[:cable_token]
    end
  end
end
