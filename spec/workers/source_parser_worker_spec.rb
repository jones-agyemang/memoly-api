require "rails_helper"

RSpec.describe SourceParserWorker, type: :worker do
  describe '#perform' do
    context "when source is parseable" do
      let(:source_intake) { create(:source_intake) }
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
        allow(SourceParser).to receive(:call).with(source_intake).and_return(arguments)
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
    end

    context "when source is unparseable" do
      it "does not call the consumer when parsing fails" do
        source_intake = create(:source_intake)

        allow(SourceParser).to receive(:call).with(source_intake)
                                             .and_raise(JSON::ParserError)

        expect(SourceConsumer).not_to receive(:call)

        expect do
          described_class.new.perform(source_intake.id)
        end.to raise_error(JSON::ParserError)
      end
    end
  end
end
