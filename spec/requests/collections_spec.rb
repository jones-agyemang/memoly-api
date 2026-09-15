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

  before do
    sign_in_with_encrypted_cookie(user)
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

  describe "PATCH /users/:user_id/collections/:id" do
    let!(:collection) { create(:collection, user: user, label: "Original Label", slug: "original-label", path: "original_label") }

    it "updates the collection label" do
      patch user_collection_url(user_id: user.id, id: collection.id),
            params: { collection: { label: "Renamed Label" } },
            headers: {}, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(a_string_including("application/json"))

      body = JSON.parse(response.body)
      expect(body["label"]).to eq("Renamed Label")
      expect(collection.reload.label).to eq("Renamed Label")
    end

    it "returns validation errors when label is blank" do
      patch user_collection_url(user_id: user.id, id: collection.id),
            params: { collection: { label: "" } },
            headers: {}, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to include("label")
    end

    it "returns not found when the collection belongs to another user" do
      other_user = create(:user)
      other_collection = create(:collection, user: other_user)

      patch user_collection_url(user_id: user.id, id: other_collection.id),
            params: { collection: { label: "Renamed Label" } },
            headers: {}, as: :json

      expect(response).to have_http_status(:not_found)
    end

    context "when reassigning a collection to a new parent" do
      let!(:destination) { create(:collection, user:, label: "New Parent", slug: "new-parent", path: "new_parent") }
      let!(:moved_child) { create(:collection, user:, label: "Movable", slug: "movable", path: "movable") }
      let!(:nested_child) { create(:collection, user:, parent: moved_child, label: "Nested", slug: "nested", path: "movable.nested") }

      it "updates the parent and refreshes descendant paths" do
        patch user_collection_url(user_id: user.id, id: moved_child.id),
              params: { collection: { parent_id: destination.id } },
              headers: {}, as: :json

        expect(response).to have_http_status(:ok)
        expect(moved_child.reload.parent_id).to eq(destination.id)
        expect(nested_child.reload.path).to start_with("#{moved_child.path}.")
      end

      it "returns unprocessable_entity when assigning to a descendant" do
        patch user_collection_url(user_id: user.id, id: moved_child.id),
              params: { collection: { parent_id: nested_child.id } },
              headers: {}, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns unprocessable_entity when assigning to another user's collection" do
        stranger_parent = create(:collection, label: "Other")

        patch user_collection_url(user_id: user.id, id: moved_child.id),
              params: { collection: { parent_id: stranger_parent.id } },
              headers: {}, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH sibling ordering" do
    before { user.collections.where(label: Collection::DEFAULT_CATEGORY_LABEL).destroy_all }

    let!(:alpha) { create(:collection, user: user, label: "Alpha", position: 1) }
    let!(:beta) { create(:collection, user: user, label: "Beta", position: 2) }
    let!(:gamma) { create(:collection, user: user, label: "Gamma", position: 3) }

    def move(record, attributes)
      patch user_collection_url(user_id: user.id, id: record.id),
            params: { collection: attributes }, headers: {}, as: :json
    end

    def ordered_ids(parent_id = nil)
      Collection.ordered_siblings(user.collections.where(parent_id: parent_id)).map(&:id)
    end

    it "moves above and below siblings and returns the persisted order" do
      move(gamma, parent_id: nil, position: 1)
      expect(response).to have_http_status(:ok)
      expect(ordered_ids).to eq([ gamma.id, alpha.id, beta.id ])
      move(gamma, parent_id: nil, position: 2)
      expect(ordered_ids).to eq([ alpha.id, gamma.id, beta.id ])
      expect(user.collections.order(:position).pluck(:position)).to eq([ 1, 2, 3 ])
      get user_collections_url(user_id: user.id), headers: {}, as: :json
      expect(response.parsed_body.map { |record| record["id"] }).to eq(ordered_ids)
    end

    it "moves across parents, compacts both groups, and refreshes descendant paths" do
      child = create(:collection, user: user, parent: alpha, label: "Child", position: 5)
      nested = create(:collection, user: user, parent: gamma, label: "Nested")
      move(gamma, parent_id: alpha.id, position: 1)
      expect(response).to have_http_status(:ok)
      expect(ordered_ids).to eq([ alpha.id, beta.id ])
      expect(ordered_ids(alpha.id)).to eq([ gamma.id, child.id ])
      expect(child.reload.position).to eq(2)
      expect(nested.reload.parent_id).to eq(gamma.id)
      expect(nested.path).to eq("#{gamma.reload.path}.nested")
      get user_collections_url(user_id: user.id), headers: {}, as: :json
      expect(response.parsed_body.first["children"].map { |record| record["id"] }).to eq([ gamma.id, child.id ])
      move(gamma, parent_id: nil, position: 3)
      expect(ordered_ids).to eq([ alpha.id, beta.id, gamma.id ])
      expect(child.reload.position).to eq(1)
      expect(nested.reload.path).to eq("#{gamma.reload.path}.nested")
    end

    it "clamps insertion slots and supports an empty destination" do
      move(gamma, position: -10)
      expect(gamma.reload.position).to eq(1)
      move(gamma, position: 100)
      expect(gamma.reload.position).to eq(3)
      move(gamma, parent_id: alpha.id, position: 100)
      expect(gamma.reload.position).to eq(1)
    end

    it "uses label and ID to resolve duplicate positions" do
      user.collections.update_all(position: 0)
      move(gamma, position: 2)
      expect(ordered_ids).to eq([ alpha.id, gamma.id, beta.id ])
      expect(Collection.ordered_siblings([
        Collection.new(id: 2, label: "Same", position: 0),
        Collection.new(id: 10, label: "Same", position: 0)
      ]).map(&:id)).to eq([ 10, 2 ])
    end

    it "leaves ordering unchanged for an already satisfied move" do
      timestamps = user.collections.order(:id).pluck(:updated_at)
      move(beta, position: 2)
      expect(response).to have_http_status(:ok)
      expect(user.collections.order(:id).pluck(:updated_at)).to eq(timestamps)
    end

    it "rolls back invalid parents, cycles, and invalid attributes" do
      nested = create(:collection, user: user, parent: gamma, label: "Nested")
      stranger = create(:collection, label: "Stranger")
      before = user.collections.order(:id).pluck(:id, :parent_id, :position, :path, :label)
      [ { parent_id: nested.id }, { parent_id: gamma.id }, { parent_id: stranger.id },
        { parent_id: 0 }, { label: "" }, { position: nil } ].each do |attributes|
        move(gamma, { position: 1 }.merge(attributes))
        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.collections.order(:id).pluck(:id, :parent_id, :position, :path, :label)).to eq(before)
      end
    end

    it "rolls back the moved record and descendant paths if a sibling save fails" do
      nested = create(:collection, user: user, parent: alpha, label: "Nested")
      # Simulate a pre-existing invalid sibling that fails during renumbering.
      beta.update_column(:label, "")
      before = user.collections.order(:id).pluck(:id, :parent_id, :position, :path)
      move(alpha, parent_id: gamma.id, position: 1)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(user.collections.order(:id).pluck(:id, :parent_id, :position, :path)).to eq(before)
      expect(nested.reload.parent_id).to eq(alpha.id)
    end
  end

  describe "DELETE /users/:user_id/collections/:id" do
    let!(:collection) { create(:collection, user:, label: "Removable", slug: "removable", path: "removable") }

    it "removes the collection and its descendants" do
      child = create(:collection, user:, parent: collection, label: "Child", slug: "child", path: "removable.child")

      delete user_collection_url(user_id: user.id, id: collection.id), headers: {}, as: :json

      expect(response).to have_http_status(:no_content)
      expect(Collection.exists?(collection.id)).to be(false)
      expect(Collection.exists?(child.id)).to be(false)
    end

    it "returns not found when attempting to delete another user's collection" do
      stranger = create(:user)
      strangers_collection = create(:collection, user: stranger)

      delete user_collection_url(user_id: user.id, id: strangers_collection.id), headers: {}, as: :json

      expect(response).to have_http_status(:not_found)
    end

    it "prevents deleting the default collection" do
      default_collection = create(:collection, user:, label: Collection::DEFAULT_CATEGORY_LABEL)

      delete user_collection_url(user_id: user.id, id: default_collection.id), headers: {}, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to include("error")
      expect(Collection.exists?(default_collection.id)).to be(true)
    end
  end
end
