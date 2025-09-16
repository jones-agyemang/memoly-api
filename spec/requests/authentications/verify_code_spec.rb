# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Verify Code", type: :request do
  describe "non-existent user" do
    before do
      post "/authentication/verify-code", params: invalid_attributes
    end

    let(:invalid_attributes) do
      {
        email: "non.existent@example.com",
        authentication_code: ""
      }
    end

    it "returns unauthorized response" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "existing user" do
    let(:user) { create(:user, :with_valid_auth) }

    before do
      post "/authentication/verify-code", params: attributes
    end

    describe "invalid authentication code" do
      let(:attributes) do
        {
          email: user.email,
          authentication_code: user.authentication_code.code + "error"
        }
      end

      it 'returns unathorized response' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe 'valid authentication' do
      let(:user) { create(:user, :with_valid_auth) }
      let(:attributes) do
        {
          email: user.email,
          authentication_code: user.authentication_code.code
        }
      end

      before do
        post "/authentication/verify-code", params: attributes
      end

      context 'when authentication code is not expired' do
        it 'successfully authenticates' do
          expect(response).to have_http_status(:created)
        end
      end

      context "when authentication code has expired" do
        let(:user) { create(:user, :with_expired_auth) }

        it 'returns unauthorized response' do
          response_body = JSON.parse(response.body)

          expect(response).to have_http_status(:unauthorized)
          expect(response_body["message"]).to match(/Verification code expired on/)
        end
      end
    end
  end
end
