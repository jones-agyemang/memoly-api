# frozen_string_literal: true

class SourceParserWorker
  include Sidekiq::Job

  PARSERS = {
    "url" => SourceParser::Url,
    "raw_text" => SourceParser::RawText,
    "pdf" => SourceParser::Pdf
  }.freeze

  def perform(source_intake_id)
    source_intake = SourceIntake.find(source_intake_id)
    parsed_source = PARSERS.fetch(source_intake.source_type).call(source_intake)

    SourceConsumer.call(source_intake, parsed_source)
    broadcast_refresh(source_intake)
  end

  private

  def broadcast_refresh(source_intake)
    NotesChannel.broadcast_to(
      source_intake.user,
      {
        type: "notes.refresh",
        source_intake_id: source_intake.id
      }
    )
  rescue StandardError => error
    Rails.error.report(
      error,
      handled: true,
      context: { source_intake_id: source_intake.id }
    )
  end
end
