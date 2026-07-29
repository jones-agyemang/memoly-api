require "rails_helper"

RSpec.describe Ocr::ExtractText, type: :service do
  describe ".call" do
    let(:image) do
      Rack::Test::UploadedFile.new(
        file_fixture("lorem-ipsum.jpeg"),
        "image/jpeg"
      )
    end
    subject(:invoke_text_extraction) { described_class.call(image) }

    describe "validation" do
      context "when not an image file" do
        let(:image) {
          Rack::Test::UploadedFile.new(
            file_fixture("lorem-ipsum.jpeg"),
            "video/mp4"
          )
        }

        it "returns as invalid" do
          expect(invoke_text_extraction.output).to eq(
            { "error" => "Invalid image file type." }
          )
        end
      end

      context "when file size is too large" do
        let(:image) { double }

        it "returns as invalid" do
          allow(image).to receive(:content_type).and_return("image/jpeg")
          allow(image).to receive(:size).and_return(20.megabytes)

          expect(invoke_text_extraction.output).to eq(
            { "error" => "Image size is above what's permitted." }
          )
        end
      end
    end

    context "when valid" do
      it "extracts text from image" do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("OPENAI_ACCESS_TOKEN").and_return("foo")

        expected_text = "Lorem ipsum"
        expected_llm_response = {
          "output"=> [
            {
              "type"=>"message",
              "content"=> [
                {
                  "type"=>"output_text",
                  "annotations"=>[],
                  "logprobs"=>[],
                  "text"=>
                   "{\"captured_output\":\"#{expected_text}\"}"
                }
              ]
            }
          ]
        }

        llm_client = instance_double(OpenAI::Client)
        allow(OpenAI::Client).to receive(:new).and_return(llm_client)

        allow(llm_client).to receive_message_chain("responses.create").and_return(expected_llm_response)

        expect(invoke_text_extraction.output).to eq(
          { "captured_output" => "Lorem ipsum" }.to_json
        )
      end
    end
  end
end
