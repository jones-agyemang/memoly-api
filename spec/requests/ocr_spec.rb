require "rails_helper"

RSpec.describe "Optical Character Recognition", type: :request do
  let(:user) { create(:user) }
  let(:access_token) { create(:access_token, user:) }

  describe "POST /ocr" do
    context "when unauthorised" do
      it "returns an unauthorized response" do
        post "/ocr"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authorized" do
      let(:headers) do
        {
          "Authorization": "Bearer #{access_token.token}"
        }
      end

      context "when image is valid" do
        it "returns extracted text" do
          image = Rack::Test::UploadedFile.new(
            file_fixture("lorem-ipsum.jpeg"),
            "image/jpeg"
          )

          expected_text = "Lorem ipsum\n\nLorem ipsum dolor sit amet, consectetur  \nadipiscing elit, sed do eiusmod tempor incididunt  \nut labore et dolore magna aliqua. Ut enim ad  \nminim veniam, quis nostrud exercitation ullamco  \nlaboris nisi ut aliquip ex ea commodo consequat."
          expected_output = double
          allow(expected_output).to receive(:success?).and_return(true)
          allow(expected_output).to receive(:output).and_return({ "captured_output" => expected_text })

          allow(Ocr::ExtractText).
            to receive(:call).
            with(instance_of(ActionDispatch::Http::UploadedFile)).
            and_return(expected_output)

          post "/ocr", params: { image: image }, headers: headers

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to eq(
            {
              "captured_output" => expected_text
            }
          )
        end
      end

      context "when image is invalid" do
        it "returns error reason" do
          image = Rack::Test::UploadedFile.new(file_fixture("lorem-ipsum.jpeg"), "video/mp4")

          post "/ocr", params: { image: image }, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
