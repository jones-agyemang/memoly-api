require "rails_helper"

RSpec.describe "Cable", type: :request do
  describe 'POST /realtime/cable-token' do
    context 'when user is not authenticated' do
      it 'returns authorisation failure response' do
        post '/realtime/cable-token', params: {}, headers: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user is authenticated' do
      let(:user) { create(:user) }
      let(:access_token) { create(:access_token, user:) }
      let(:headers) do
        {
          "Authorization": "Bearer #{access_token.token}"
        }
      end

      it 'returns a short-lived cable token' do
        post '/realtime/cable-token', headers: headers

        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to include("token" => be_a(String))
      end

      it 'verifies token ownership and usage purpose' do
        post '/realtime/cable-token', headers: headers

        owner = user
        token = response.parsed_body.fetch('token')
        expected_owner = User.find_signed!(token, purpose: :action_cable)

        expect(owner).to eq(expected_owner)
      end
    end
  end
end
