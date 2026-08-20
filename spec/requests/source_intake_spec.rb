
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

  subject(:post_source!) do
    post "/users/#{user.id}/source_intake", params: attributes, headers: headers
  end

  def uploaded_pdf(content: "%PDF-1.4\n%%EOF", filename: "lecture-notes.pdf", total_size: nil)
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile.write(content)
    tempfile.truncate(total_size) if total_size
    tempfile.rewind

    Rack::Test::UploadedFile.new(tempfile.path, "application/pdf", original_filename: filename)
  end

  describe "`pdf` source" do
    it "accepts and attaches a PDF for background generation" do
      post "/users/#{user.id}/source_intake",
        params: { source_type: "pdf", pdf: uploaded_pdf, public: true },
        headers: headers

      expect(response).to have_http_status(:accepted)
      source_intake = SourceIntake.order(:id).last
      expect(source_intake).to be_a(PdfSource)
      expect(source_intake).to have_attributes(source: "lecture-notes.pdf", public: true)
      expect(source_intake.document).to be_attached
      expect(SourceParserWorker.jobs).not_to be_empty
    end

    it "rejects a PDF over 5 MB before persistence" do
      expect do
        post "/users/#{user.id}/source_intake",
          params: {
            source_type: "pdf",
            pdf: uploaded_pdf(total_size: PdfSource::MAX_FILE_SIZE + 1)
          },
          headers: headers
      end.not_to change(SourceIntake, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body.fetch("message")).to include("5 MB")
      expect(ActiveStorage::Blob.count).to eq(0)
    end

    it "rejects a non-PDF upload" do
      post "/users/#{user.id}/source_intake",
        params: {
          source_type: "pdf",
          pdf: uploaded_pdf(content: "plain text", filename: "notes.pdf")
        },
        headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body.fetch("message")).to include("Only PDF")
      expect(ActiveStorage::Blob.count).to eq(0)
    end
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

  describe "`url` source" do
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

        context "when source url is unreachable" do
          let(:attributes) { { source_type: "url", source: Faker::Internet.url } }

          it "responds with service connection error" do
            post_source!

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body).to eq({ "message" => [ "Source type is unreachable" ] })
          end
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
