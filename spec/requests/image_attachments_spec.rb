require "rails_helper"
require "base64"

RSpec.describe "Image attachments", type: :request do
  let(:user) { create(:user) }
  let(:access_token) { create(:access_token, user:) }
  let(:headers) { { "Authorization" => "Bearer #{access_token.token}" } }
  let(:collection) { create(:collection, user:) }
  let(:note) { create(:note, collection:) }
  let(:png_bytes) do
    Base64.decode64(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    )
  end

  def uploaded_file(bytes: png_bytes, filename: "diagram.png", content_type: "image/png", total_size: nil)
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile.write(bytes)
    tempfile.truncate(total_size) if total_size
    tempfile.rewind

    Rack::Test::UploadedFile.new(
      tempfile.path,
      content_type,
      original_filename: filename
    )
  end

  before do
    processed_variant = instance_double(ActiveStorage::VariantWithRecord, url: "https://images.example/variant")
    variant = instance_double(ActiveStorage::VariantWithRecord, processed: processed_variant)

    allow_any_instance_of(ActiveStorage::Attachment).to receive(:variant).and_return(variant)
    allow_any_instance_of(ActiveStorage::Blob).to receive(:url).and_return("https://images.example/original")
  end

  it "attaches a detected image to a note and returns responsive URLs and Markdown" do
    post "/users/#{user.id}/notes/#{note.id}/images",
      params: { image: uploaded_file },
      headers: headers

    expect(response).to have_http_status(:created)
    expect(note.reload.images).to be_attached
    expect(note.images.first.key).to match(
      %r{\A[0-9a-f]{32}/[0-9a-f]{32}/[0-9a-f]{48}\z}
    )
    expect(response.parsed_body).to include(
      "content_type" => "image/png",
      "markdown" => "![diagram](https://images.example/variant)",
      "variants" => {
        "large" => "https://images.example/variant",
        "medium" => "https://images.example/variant",
        "small" => "https://images.example/variant"
      }
    )
  end

  it "generates usable Disk service URLs in local-style storage" do
    allow_any_instance_of(ActiveStorage::Attachment).to receive(:variant).and_call_original
    allow_any_instance_of(ActiveStorage::Blob).to receive(:url).and_call_original

    post "/users/#{user.id}/notes/#{note.id}/images",
      params: { image: uploaded_file },
      headers: headers

    expect(response).to have_http_status(:created)
    expect(response.parsed_body.fetch("url")).to start_with(
      "http://www.example.com/rails/active_storage/disk/"
    )
    expect(response.parsed_body.dig("variants", "medium")).to start_with(
      "http://www.example.com/rails/active_storage/disk/"
    )
  end

  it "supports collections as attachment owners" do
    post "/users/#{user.id}/collections/#{collection.id}/images",
      params: { image: uploaded_file(filename: "cover.jpeg") },
      headers: headers

    expect(response).to have_http_status(:created)
    expect(collection.reload.images).to be_attached
  end

  it "rejects content whose detected type is unsupported" do
    post "/users/#{user.id}/notes/#{note.id}/images",
      params: { image: uploaded_file(bytes: "plain text", filename: "notes.png") },
      headers: headers

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body.fetch("message")).to include("Only PNG")
    expect(ActiveStorage::Blob.count).to eq(0)
  end

  it "rejects an image over 10 MiB before creating a blob" do
    post "/users/#{user.id}/notes/#{note.id}/images",
      params: {
        image: uploaded_file(total_size: ImageAttachable::MAX_IMAGE_SIZE + 1)
      },
      headers: headers

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body.fetch("message")).to include("10 MB")
    expect(ActiveStorage::Blob.count).to eq(0)
  end

  it "does not allow a user to attach an image to another user's record" do
    other_note = create(:note, collection: create(:collection))

    post "/users/#{user.id}/notes/#{other_note.id}/images",
      params: { image: uploaded_file },
      headers: headers

    expect(response).to have_http_status(:not_found)
    expect(ActiveStorage::Blob.count).to eq(0)
  end
end
