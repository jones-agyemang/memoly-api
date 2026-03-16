# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateQuiz, type: :service do
  context 'when there is no topic' do
    it 'does not create a quiz' do
      quiz_response = described_class.call('')

      expect(quiz_response).to eq([])
    end
  end

  context 'when there is a single topic' do
    it 'returns the quiz for that topic' do
      VCR.use_cassette('create_quiz') do
        quiz_response = described_class.call('Gradient-descent is an optimisation method.')
        expect(quiz_response).to match_response_schema('quiz')
      end
    end
  end
end
