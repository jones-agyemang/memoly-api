require "rails_helper"

RSpec.describe SourceParser::Pdf do
  let(:source_intake) { create(:pdf_source, source: "machine-learning.pdf") }
  let(:client) { instance_double(OpenAI::Client) }
  let(:responses_client) { instance_double(OpenAI::Responses) }

  it "passes the attached PDF directly to the model as a file input" do
    allow(client).to receive(:responses).and_return(responses_client)
    allow(responses_client).to receive(:create).and_return({
      "output" => [ {
        "type" => "function_call",
        "name" => "source_notes",
        "arguments" => '{"collections":{}}'
      } ]
    })

    described_class.call(source_intake, client:)

    expect(responses_client).to have_received(:create) do |parameters:|
      user_content = parameters.fetch(:input).find { |input| input[:role] == "user" }.fetch(:content)
      file_input = user_content.find { |content| content[:type] == "input_file" }
      text_input = user_content.find { |content| content[:type] == "input_text" }

      expect(file_input).to include(
        filename: "machine-learning.pdf",
        file_data: start_with("data:application/pdf;base64,")
      )
      encoded_pdf = file_input.fetch(:file_data).split(",", 2).last
      expect(Base64.strict_decode64(encoded_pdf)).to include("%PDF-1.4")
      expect(text_input.fetch(:text)).to include("Use the attached PDF")
      expect(parameters.fetch(:tools)).to include(
        type: "web_search",
        search_context_size: "high"
      )
    end
  end
end
