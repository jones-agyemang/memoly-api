require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /users by Email" do
    let(:user) { create(:user) }

    context "when user exists" do
      it "returns http success" do
        get "/users?email=#{user.email}"

        response_body = JSON.parse(response.body)

        expected_response_body = {
          "id" => user.id,
          "email" => user.email,
          "first_name" => user&.first_name,
          "last_name" => user&.last_name
        }

        expect(response).to have_http_status :success
        expect(response_body).to eq expected_response_body
      end
    end

    context "when user does not exist" do
      it 'returns nothing' do
        get "/users?email=non.existent@example.com"

        response_body = JSON.parse(response.body)

        expected_response_body = {
          "message" => "User not found"
        }

        expect(response).to have_http_status :not_found
        expect(response_body).to eq expected_response_body
      end
    end
  end
end
