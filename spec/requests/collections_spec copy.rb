require 'rails_helper'

RSpec.describe "/collections", type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) do
    {
      user_id: user.id,
      label: "Computer Science",
      slug: "computer_science",
      parent: "",
      path: "",
      position: 0
    }
  end

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let(:valid_headers) {
    {}
  }

  # describe "GET /index" do
  #   it "renders a successful response" do
  #     Collection.create! valid_attributes
  #     get collections_url, headers: valid_headers, as: :json
  #     expect(response).to be_successful
  #   end
  # end

  # describe "GET /show" do
  #   it "renders a successful response" do
  #     collection = Collection.create! valid_attributes
  #     get collection_url(collection), as: :json
  #     expect(response).to be_successful
  #   end
  # end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Collection" do
        expect {
          post collections_url,
               params: { collection: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Collection, :count).by(1)
      end

      it "renders a JSON response with the new collection" do
        post collections_url,
             params: { collection: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  # describe "PATCH /update" do
  #   context "with valid parameters" do
  #     let(:new_attributes) {
  #       skip("Add a hash of attributes valid for your model")
  #     }

  #     it "updates the requested collection" do
  #       collection = Collection.create! valid_attributes
  #       patch collection_url(collection),
  #             params: { collection: new_attributes }, headers: valid_headers, as: :json
  #       collection.reload
  #       skip("Add assertions for updated state")
  #     end

  #     it "renders a JSON response with the collection" do
  #       collection = Collection.create! valid_attributes
  #       patch collection_url(collection),
  #             params: { collection: new_attributes }, headers: valid_headers, as: :json
  #       expect(response).to have_http_status(:ok)
  #       expect(response.content_type).to match(a_string_including("application/json"))
  #     end
  #   end

  #   context "with invalid parameters" do
  #     it "renders a JSON response with errors for the collection" do
  #       collection = Collection.create! valid_attributes
  #       patch collection_url(collection),
  #             params: { collection: invalid_attributes }, headers: valid_headers, as: :json
  #       expect(response).to have_http_status(:unprocessable_entity)
  #       expect(response.content_type).to match(a_string_including("application/json"))
  #     end
  #   end
  # end

  # describe "DELETE /destroy" do
  #   it "destroys the requested collection" do
  #     collection = Collection.create! valid_attributes
  #     expect {
  #       delete collection_url(collection), headers: valid_headers, as: :json
  #     }.to change(Collection, :count).by(-1)
  #   end
  # end
end
