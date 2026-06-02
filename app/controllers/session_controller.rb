class SessionController < ApplicationController
  def logout
    current_user.access_tokens&.map { _1.revoke }
  end
end
