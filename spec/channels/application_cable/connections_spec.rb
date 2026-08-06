require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { create(:user) }
  subject(:establish_connection) { connect params: { cable_token: token } }

  context 'with a valid context token' do
    let(:token) { user.signed_id(purpose: :action_cable, expires_in: 10.minutes) }

    it 'accepts connection for token owner' do
      establish_connection
      expect(connection.current_user).to eq(user)
    end
  end

  context 'invalid token' do
    let(:token) { "invalid-foo-token" }

    it 'rejects the connection' do
      expect do
        establish_connection
      end.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature, 'mismatched digest')
    end
  end

  context "with missing token" do
    let(:token) { nil }

    it "rejects the connection" do
      expect do
        establish_connection
      end.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature, 'mismatched digest')
    end
  end

  context 'with an invalid token purpose' do
    let(:token) { user.signed_id(purpose: :invalid_token_purpose) }

    it 'rejects the connection' do
      expect do
        establish_connection
      end.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature, "mismatched purpose")
    end
  end

  context "with subscriber-provided user_id" do
    let(:token) { nil }

    it "rejects non-token-based authentication means" do
      expect do
        connect params: { cable_token: token, user_id: user.id }
      end.to raise_error(ApplicationCable::InvalidAuthenticationMeansError, "Subscriber-provided `user_id` cannot be accepted")
    end
  end
end
