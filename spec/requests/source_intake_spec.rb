require 'rails_helper'

RSpec.describe "SourceIntakes", type: :request do
  let(:user) { create(:user) }
  let(:access_token) { create(:access_token, user: user) }
  let(:headers) do
    {
      "ACCEPT" => "application/json",
      "Authorization" => "Bearer #{access_token.token}"
    }
  end

  describe "POST /users/:id/source_intake" do
    describe "valid attributes" do
      let(:valid_attributes) { { source_type: "url", source: "https://www.reactjs.com" } }

      it "returns http success" do
        post "/users/#{user.id}/source_intake", params: valid_attributes, headers: headers

        expect(response).to have_http_status(:success)
      end
    end

    describe 'invalid attributes' do
      let(:valid_attributes) { { source_type: 'foo', source: "https://www.reactjs.com" } }

      it 'returns an error' do
        post "/users/#{user.id}/source_intake", params: valid_attributes, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body).dig('message').join(', ')).to match(/Source type is not included in the list/)
      end
    end
  end
end
