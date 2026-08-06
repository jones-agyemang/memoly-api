require "rails_helper"

RSpec.describe NotesChannel, type: :channel do
  describe "#subscribed" do
    let(:user) { create(:user) }

    before do
      stub_connection current_user: user
    end

    it "confirms the subscription" do
      subscribe

      expect(subscription).to be_confirmed
    end

    it "streams broadcasts for the current user" do
      subscribe

      expect(subscription).to have_stream_for(user)
    end

    it "does not stream broadcast for unauthenticated other user" do
      unsubscribed_user = create(:user)

      subscribe

      expect(subscription).not_to have_stream_for(unsubscribed_user)
    end
  end
end
