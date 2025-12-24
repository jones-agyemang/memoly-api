require 'rails_helper'

RSpec.describe "Discovery", type: :request do
  describe "GET /discovery" do
    let!(:public_collection) { create(:collection, :public_collection, label: "Physics") }
    let!(:public_note) { create(:note, :public_note, collection: public_collection, raw_content: "Quantum fields") }
    let!(:private_note) { create(:note, collection: public_collection, raw_content: "Draft section") }
    let!(:private_collection) { create(:collection, label: "Secret Stuff") }
    let!(:private_note_under_private_collection) { create(:note, :public_note, collection: private_collection, raw_content: "Hidden but public flagged") }
    let!(:parent_private) { create(:collection, label: "Parent Private") }
    let!(:child_public_with_private_parent) do
      create(:collection, :public_collection, parent: parent_private, user: parent_private.user, label: "Child Public")
    end
    let!(:child_note) { create(:note, :public_note, collection: child_public_with_private_parent, raw_content: "Should not leak") }

    it "returns only public collections and their public notes" do
      get "/discovery", headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body.size).to eq(1)

      physics = body.find { |c| c["label"] == "Physics" }
      expect(physics).not_to be_nil

      note_texts = physics.fetch("notes").map { |note| note["raw_content"] }
      expect(note_texts).to include(public_note.raw_content)
      expect(note_texts).not_to include(private_note.raw_content)
      expect(body.to_s).not_to include(private_collection.label)
      expect(body.to_s).not_to include(child_note.raw_content)
      expect(body.to_s).not_to include(private_note_under_private_collection.raw_content)
    end

    it "filters collections and notes by query" do
      extra_note = create(:note, :public_note, collection: public_collection, raw_content: "Gravitational lensing")

      get "/discovery", params: { q: "lensing" }, headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      physics = body.find { |c| c["label"] == "Physics" }
      expect(physics).not_to be_nil

      note_texts = physics.fetch("notes").map { |note| note["raw_content"] }
      expect(note_texts).to match_array([ extra_note.raw_content ])
    end

    it "keeps ancestors when a descendant matches the query" do
      public_parent = create(:collection, :public_collection, label: "Sciences")
      child = create(:collection, :public_collection, parent: public_parent, user: public_parent.user, label: "Physics Deep Dive")
      matching_note = create(:note, :public_note, collection: child, raw_content: "Optics basics")

      get "/discovery", params: { q: "optics" }, headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      sciences = body.find { |c| c["label"] == "Sciences" }
      expect(sciences).not_to be_nil

      nested = sciences.fetch("children").find { |c| c["label"] == "Physics Deep Dive" }
      expect(nested).not_to be_nil
      expect(nested.fetch("notes").first["raw_content"]).to eq(matching_note.raw_content)
    end
  end
end
