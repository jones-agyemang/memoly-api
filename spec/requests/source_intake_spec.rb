
require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe "SourceIntakes", type: :request do
  let(:user) { create(:user) }
  let(:access_token) { create(:access_token, user: user) }
  let(:headers) do
    {
      "ACCEPT" => "application/json",
      "Authorization" => "Bearer #{access_token.token}"
    }
  end

  before do
    Sidekiq::Worker.clear_all
  end

  describe "`raw_text` source" do
    describe "POST /users/:id/source_intake" do
      let(:valid_attributes) do
        {
          source_type: "raw_text",
          source: "Aggregates such as MIN and MAX also follow enum ordering"
        }
      end
      it "returns http success" do
        post "/users/#{user.id}/source_intake", params: valid_attributes, headers: headers

        expect(response).to have_http_status(:accepted)
        expect(JSON.parse(response.body)).to include(
          'source_type' => 'raw_text',
          'source' => "Aggregates such as MIN and MAX also follow enum ordering",
          'status' => 'pending',
          'validation_result' => {},
          'error_reason' => nil
        )
      end
    end
  end

  describe "URL source" do
    describe "POST /users/:id/source_intake" do
      describe "valid attributes" do
        let(:valid_attributes) { { source_type: "url", source: "https://www.reactjs.com" } }

        it "returns http success" do
          post "/users/#{user.id}/source_intake", params: valid_attributes, headers: headers

          expect(response).to have_http_status(:accepted)
          expect(JSON.parse(response.body)).to include(
            'source_type' => 'url',
            'source' => 'https://www.reactjs.com',
            'status' => 'pending',
            'validation_result' => {},
            'error_reason' => nil
          )
        end

        it "enqueues a source parser worker" do
          expect do
            post "/users/#{user.id}/source_intake", params: valid_attributes, headers: headers
          end.to change(SourceParserWorker.jobs, :size).by(1)
        end
      end

      describe 'invalid attributes' do
        let(:invalid_attributes) { { source_type: 'foo', source: "https://www.reactjs.com" } }

        it 'returns an error' do
          post "/users/#{user.id}/source_intake", params: invalid_attributes, headers: headers

          response_body = JSON.parse(response.body).dig('message').join(', ')

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response_body).to match(/Source type is not included in the list/)
        end
      end
    end
  end
end
