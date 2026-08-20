require "rails_helper"

RSpec.describe SourceParserWorker, type: :worker do
  describe "options" do
    it "forbids retries" do
      expect(described_class.sidekiq_options["retry"]).to be(false)
    end
  end

  describe '#perform' do
    let(:source_intake) { create(:url_source) }

    context "when source is parseable" do
      let(:arguments) do
        {
          collections: {
            "Sidekiq API" => {
              parent_label: nil,
              position: 0,
              notes: [ "# Intro" ]
            }
          }
        }
      end

      before do
        allow(SourceParser::Url).to receive(:call).with(source_intake).and_return(arguments)
      end

      it "parses the source and consumes the parsed source" do
        expect(SourceConsumer).to receive(:call).with(source_intake, arguments)

        described_class.new.perform(source_intake.id)
      end

      it "should broadcast completion to notes channel" do
        expect(NotesChannel).to receive(:broadcast_to).with(
          source_intake.user,
          hash_including(type: "notes.refresh", source_intake_id: source_intake.id)
        )

        described_class.new.perform(source_intake.id)
      end

      it "does not raise when broadcasting completion fails" do
        broadcast_error = StandardError.new("broadcast failed")

        expect(SourceConsumer).to receive(:call).with(source_intake, arguments)
        allow(NotesChannel).to receive(:broadcast_to).and_raise(broadcast_error)
        expect(Rails.error).to receive(:report).with(
          broadcast_error,
          handled: true,
          context: { source_intake_id: source_intake.id }
        )

        expect do
          described_class.new.perform(source_intake.id)
        end.not_to raise_error
      end
    end

    context "with each supported source type" do
      let(:arguments) { { collections: {} } }

      {
        url_source: SourceParser::Url,
        raw_text: SourceParser::RawText,
        pdf_source: SourceParser::Pdf
      }.each do |factory, parser|
        it "dispatches #{factory} to #{parser}" do
          source = create(factory)
          allow(parser).to receive(:call).with(source).and_return(arguments)

          described_class.new.perform(source.id)

          expect(parser).to have_received(:call).with(source)
        end
      end
    end

    context "when source is unparseable" do
      it "does not call the consumer when parsing fails" do
        allow(SourceParser::Url).to receive(:call).with(source_intake)
                                             .and_raise(JSON::ParserError)

        expect(SourceConsumer).not_to receive(:call)

        expect do
          described_class.new.perform(source_intake.id)
        end.to raise_error(JSON::ParserError)
      end
    end
  end
end
