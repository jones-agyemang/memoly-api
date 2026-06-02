require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /logout" do
    let(:user) { create(:user) }

    it "returns http success" do
      sign_in_with_encrypted_cookie(user)

      delete "/session/logout"
      expect(response).to have_http_status(:no_content)
    end
  end
end
