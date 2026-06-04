require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "DELETE /session/logout" do
    let(:user) { create(:user) }

    it "revokes access tokens, clears the access token cookie, and returns no content" do
      access_token = sign_in_with_encrypted_cookie(user)

      delete "/session/logout"

      expect(response).to have_http_status(:no_content)
      expect(access_token.reload).to be_revoked
      expect(response.headers["Set-Cookie"]).to include("access_token=")
      expect(response.headers["Set-Cookie"]).to include("max-age=0")
    end
  end
end
