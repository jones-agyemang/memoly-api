require 'rails_helper'

RSpec.describe SourceIntake, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:source_type) }
    it { is_expected.to validate_presence_of(:source) }
    it { is_expected.to validate_inclusion_of(:source_type).in_array(%w[url]) }

    it 'only accepts supported processing statuses' do
      expect(described_class.statuses.keys).to eq(described_class::STATUSES)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'source URL' do
    it 'exposes the persisted source as the original URL' do
      source_intake = build(:source_intake)

      expect(source_intake.original_url).to eq(source_intake.source)
    end
  end

  describe 'processing state' do
    let(:source_intake) { create(:source_intake) }
    let(:validation_result) { { 'valid' => true, 'content_type' => 'text/html' } }

    it 'starts pending' do
      expect(source_intake).to be_pending
    end

    it 'moves a validated and stored artifact through import to completion' do
      source_intake.mark_queued!(validation_result:)

      expect(source_intake).to have_attributes(
        status: 'queued',
        validation_result: validation_result,
        error_reason: nil
      )

      source_intake.mark_processing!
      expect(source_intake).to be_processing

      source_intake.mark_completed!
      expect(source_intake).to be_completed
    end

    it 'records a validation rejection without storing a generated payload' do
      result = { 'valid' => false, 'reason' => 'unsupported content type' }

      source_intake.mark_rejected!(
        validation_result: result,
        error_reason: 'unsupported content type'
      )

      expect(source_intake).to have_attributes(
        status: 'rejected',
        validation_result: result,
        error_reason: 'unsupported content type'
      )
    end

    it 'records generation failure' do
      source_intake.mark_generation_failed!(
        validation_result: validation_result,
        error_reason: 'model response was invalid'
      )

      expect(source_intake).to have_attributes(
        status: 'generation_failed',
        validation_result: validation_result,
        error_reason: 'model response was invalid'
      )
    end

    it 'records storage failure' do
      source_intake.mark_storage_failed!(
        validation_result: validation_result,
        error_reason: 'object storage unavailable'
      )

      expect(source_intake).to have_attributes(
        status: 'storage_failed',
        validation_result: validation_result,
        error_reason: 'object storage unavailable'
      )
    end

    it 'records import failure after the artifact is queued' do
      source_intake.mark_queued!(validation_result:)
      source_intake.mark_processing!
      source_intake.mark_failed!(error_reason: 'note import failed')

      expect(source_intake).to have_attributes(
        status: 'failed',
        error_reason: 'note import failed'
      )
    end

    it 'rejects an out-of-order worker transition' do
      expect { source_intake.mark_completed! }
        .to raise_error(
          SourceIntake::InvalidStatusTransition,
          'cannot transition from pending to completed'
        )
    end

    it 'rejects direct invalid status changes' do
      expect { source_intake.update!(status: 'completed') }
        .to raise_error(ActiveRecord::RecordInvalid, /cannot transition from pending to completed/)
    end

    it 'requires an object for structured validation results' do
      source_intake.validation_result = [ 'valid' ]

      expect(source_intake).not_to be_valid
      expect(source_intake.errors[:validation_result]).to include('must be an object')
    end
  end
end
