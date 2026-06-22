# frozen_string_literal: true

class SourceParserWorker
  include Sidekiq::Job

  def perform(source_intake_id)
    SourceParser.call(source_intake_id:)
  end
end
