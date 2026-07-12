require "rails_helper"

RSpec.describe SourceConsumer, type: :service do
  describe '.call' do
    let!(:source_intake) { create(:source_intake) }

    context "when resultset is empty" do
      let(:arguments) { {} }

      [ Collection, Note ].each do |resource|
        it "does not create #{resource}" do
          expect { described_class.call(source_intake, arguments) }.not_to change(resource, :count)
        end
      end
    end

    context "when resultset is populated" do
      let(:arguments) do
        {
          collections: {
            "Sidekiq API" => {
              parent_label: nil,
              position: 0,
              notes: []
            },
            "Sidekiq API: Workers" => {
              parent_label: "Sidekiq API",
              position: 0,
              notes: [
                "# Workers\nWorkers define background job behaviour and expose a `perform` method.",
                "## Arguments\nPass simple JSON-compatible arguments to jobs so they can be safely serialized."
              ]
            },
            "Sidekiq API: Queues" => {
              parent_label: "Sidekiq API",
              position: 1,
              notes: [
                "# Queues\nQueues separate workloads by priority or domain.",
                "## Queue Selection\nUse named queues when different jobs need different processing priority.",
                "## Queue\n Lorem Lorem Ipsum"
              ]
            }
          }
        }
      end

      it "creates identified resources" do
        described_class.call(source_intake, arguments)

        collection = Collection.find_by(label: "Sidekiq API")
        expect(collection.parent).to be_nil
        expect(collection.notes.count).to eq(0)

        collection = Collection.find_by(label: "Sidekiq API: Workers")
        expect(collection.parent).not_to be_nil
        expect(collection.notes.count).to eq(2)

        collection = Collection.find_by(label: "Sidekiq API: Queues")
        expect(collection.parent).not_to be_nil
        expect(collection.notes.count).to eq(3)
      end
    end
  end
end
