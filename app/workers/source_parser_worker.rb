# frozen_string_literal: true

class SourceParserWorker
  include Sidekiq::Job

  def perform(source_intake_id)
    parsed_source = SourceParser.call(source_intake_id:)
    SourceConsumer.call(SourceIntake.find(source_intake_id), parsed_source)
  end
end
