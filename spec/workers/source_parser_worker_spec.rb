require "rails_helper"

RSpec.describe SourceParserWorker, type: :worker do
  describe '#perform' do
    it 'delegates parsing to SourceParser with source intake id' do
      source_intake_id = 1
      expect(SourceParser).to receive(:call).with(source_intake_id:)

      described_class.new.perform(source_intake_id)
    end
  end
end
