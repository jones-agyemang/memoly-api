require 'rails_helper'

RSpec.describe "/collections", type: :request do
  let!(:user) { create(:user) }
  let(:valid_attributes) do
    {
      user: user.email,
      label: "Computer Science",
      parent: "",
      position: 0
    }
  end

  let(:invalid_attributes) do
    {
      user: user.email,
      label: "",
      parent: "",
      position: 0
    }
  end

  describe "POST create" do
    subject(:create_collection) do
      post user_collections_url(user_id: user.id), params: attributes, headers: {}, as: :json
    end

    context "with valid parameters" do
      let(:attributes) { valid_attributes }

      it "creates a new Collection" do
        expect { create_collection }.to change(user.collections, :count).by(1)
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
      let!(:parent) { create(:collection, user: user, label: "Core Mathematics", slug: "mathematics", path: "mathematics") }

      let(:attributes) do
        {
          user: user.email,
          label: "Linear Algebra",
          parent_id: parent.id,
          position: 1
        }
      end

      it "creates a new child Collection linked to the parent" do
        expect { create_collection }.to change(Collection, :count).by(1)

        create_collection

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))

        expected_attributes = {
          "user_id" => user.id,
          "label" => "Linear Algebra",
          "parent_id" => parent.id,
          "path" => "core_mathematics.linear_algebra",
          "position" => 1,
          "slug" => "linear-algebra"
        }

        body = JSON.parse(response.body)

        expect(body).to include(expected_attributes)
      end
    end
  end

  describe "GET index" do
    context "when scoping to a user" do
      let!(:parent) { create(:collection, user: user, label: "Core Mathematics", slug: "core_mathematics", path: "core_mathematics") }
      let!(:child) { create(:collection, user: user, label: "Linear Algebra", parent: parent, position: 1) }
      let!(:other_user) { create(:user) }
      let!(:other_collection) { create(:collection, user: other_user, label: "Other Stuff") }

      it "returns only the user's root collections with nested children" do
        get user_collections_url(user_id: user.id), headers: {}, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))

        body = JSON.parse(response.body)
        expect(body).to be_an(Array)

        expect(body.length).to eq(2)
        root = body.second
        expect(root["label"]).to eq("Core Mathematics")

        expect(root["children"]).to be_an(Array)
        expect(root["children"].first["label"]).to eq("Linear Algebra")
      end
    end
  end
end
