class SessionController < ApplicationController
  def logout
    current_user&.access_tokens&.find_each(&:revoke)

    cookies.delete(
      :access_token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    )

    head :no_content
  end
end
