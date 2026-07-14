class SourceIntake < ApplicationRecord
  class InvalidStatusTransition < StandardError; end

  STATUSES = %w[
    pending
    rejected
    generation_failed
    storage_failed
    queued
    processing
    completed
    failed
  ].freeze

  FAILURE_STATUSES = %w[rejected generation_failed storage_failed failed].freeze

  ALLOWED_STATUS_TRANSITIONS = {
    "pending" => %w[rejected generation_failed storage_failed queued],
    "queued" => %w[processing failed],
    "processing" => %w[completed failed]
  }.freeze

  belongs_to :user

  enum :status, STATUSES.index_with(&:itself), default: "pending", validate: true

  validates :source_type, :source, presence: true
  validates :source_type, inclusion: %w[ url ]
  validate :validation_result_is_structured
  validate :state_metadata_is_present
  validate :status_transition_is_allowed, on: :update

  alias_attribute :original_url, :source

  def mark_rejected!(validation_result:, error_reason:)
    transition_to!("rejected", validation_result:, error_reason:)
  end

  def mark_generation_failed!(validation_result:, error_reason:)
    transition_to!("generation_failed", validation_result:, error_reason:)
  end

  def mark_storage_failed!(validation_result:, error_reason:)
    transition_to!("storage_failed", validation_result:, error_reason:)
  end

  def mark_queued!(validation_result:)
    transition_to!("queued", validation_result:, error_reason: nil)
  end

  def mark_processing!
    transition_to!("processing")
  end

  def mark_completed!
    transition_to!("completed")
  end

  def mark_failed!(error_reason:)
    transition_to!("failed", error_reason:)
  end

  private

  def transition_to!(next_status, attributes = {})
    with_lock do
      allowed_statuses = ALLOWED_STATUS_TRANSITIONS.fetch(status, [])

      unless allowed_statuses.include?(next_status)
        raise InvalidStatusTransition, "cannot transition from #{status} to #{next_status}"
      end

      update!(attributes.merge(status: next_status))
    end
  end

  def validation_result_is_structured
    return if validation_result.is_a?(Hash)

    errors.add(:validation_result, "must be an object")
  end

  def state_metadata_is_present
    if status != "pending" && validation_result.blank?
      errors.add(:validation_result, "must be present after validation")
    end

    if FAILURE_STATUSES.include?(status) && error_reason.blank?
      errors.add(:error_reason, "must be present for a failure state")
    end
  end

  def status_transition_is_allowed
    return unless will_save_change_to_status?

    previous_status = status_in_database
    return if ALLOWED_STATUS_TRANSITIONS.fetch(previous_status, []).include?(status)

    errors.add(:status, "cannot transition from #{previous_status} to #{status}")
  end
end
