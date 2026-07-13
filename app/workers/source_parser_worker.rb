# frozen_string_literal: true

class SourceParserWorker
  include Sidekiq::Job

  def perform(source_intake_id)
    source_intake = SourceIntake.find(source_intake_id)

    parsed_source = SourceParser.call(source_intake)
    SourceConsumer.call(source_intake, parsed_source)
  end
end
