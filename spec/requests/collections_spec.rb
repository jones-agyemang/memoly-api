require 'rails_helper'

RSpec.describe "/collections", type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) do
    {
      collection: {
        user_id: user.id,
        label: "Computer Science",
        slug: "computer_science",
        parent: "",
        path: "",
        position: 0
      }
    }
  end

  let(:invalid_attributes) do
    {
      collection: {
        user_id: "NON-EXISTING-USER-ID",
        label: "Linear Algebra",
        slug: "linear_algebra",
        parent: "",
        path: "",
        position: 0
      }
    }
  end

  describe "POST /create" do
    subject(:create_collection) do
      post collections_url, params: attributes, headers: {}, as: :json
    end

    context "with valid parameters" do
      let(:attributes) { valid_attributes }

      it "creates a new Collection" do
        expect { create_collection }.to change(Collection, :count).by(1)
      end

      it "renders a JSON response with the new collection" do
        create_collection

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      let(:attributes) { invalid_attributes }

      it "does not create a new Collection" do
        expect { create_collection }.to change(Collection, :count).by(0)
      end

      it "renders a JSON response with errors for the new collection" do
        create_collection

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "when adding a collection under an existing parent" do
      let!(:parent) { create(:collection, user: user, label: "Mathematics", slug: "mathematics", path: "") }

      let(:attributes) do
        {
          collection: {
            user_id: user.id,
            label: "Algebra",
            slug: "algebra",
            parent_id: parent.id,
            path: parent.path,
            position: 1
          }
        }
      end

      it "creates a new child Collection linked to the parent" do
        expect { create_collection }.to change(Collection, :count).by(1)

        create_collection

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))

        body = JSON.parse(response.body)
        puts body
        expect(body["parent_id"]).to eq(parent.id)
      end
    end
  end
end
