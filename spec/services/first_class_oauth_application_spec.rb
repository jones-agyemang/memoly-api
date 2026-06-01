# frozen_string_literal: true

require "rails_helper"

RSpec.describe FirstClassOauthApplication, type: :service do
  describe 'call' do
    context 'when application does not exists' do
      it 'raises an error' do
        expect do
          described_class.call
        end.to raise_error(FirstClassOauthApplication::UninitialisedApplication)
      end
    end

    context 'when application exists' do
      it 'returns application' do
        create_first_class_oauth_application

        oauth_application = described_class.call
        expect(oauth_application).to be_a(Doorkeeper::Application)
      end
    end
  end
end
