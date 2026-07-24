# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentications', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  describe 'POST /request-code' do
    context 'invalid attributes' do
      it 'does not create code' do
        post '/authentication/request-code', params: { email: '' }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'valid attributes' do
      context 'user exists' do
        let(:user) { create(:user) }
        let(:valid_attributes) do
          { email: user.email }
        end

        it 'creates request code' do
          post '/authentication/request-code', params: valid_attributes

          expect(response).to have_http_status(:created)
        end

        it "sends the requested code immediately" do
          expect do
            post '/authentication/request-code', params: valid_attributes
          end.to change(ActionMailer::Base.deliveries, :count).by(1)
        end

        context "user have been previously issued with a code" do
          it "replaces it with a code that is valid for the next 15 minutes" do
            previous_code = create(:authentication_code, user:, expires_at: 1.day.ago)
            requested_at = Time.zone.local(2026, 7, 24, 12, 0, 0)

            allow(SecureRandom).to receive(:random_number).and_return(9)

            travel_to(requested_at) do
              post '/authentication/request-code', params: valid_attributes

              expect(previous_code.reload).to have_attributes(
                code: "999999",
                expires_at: requested_at + 15.minutes
              )
              expect(previous_code.expires_at).to be_future
            end
          end
        end
      end

      context 'user does not exist' do
        it 'creates request code for new user' do
          expect do
            post '/authentication/request-code', params: { email: 'test@example.com' }
          end.to change(ActionMailer::Base.deliveries, :count).by(1)

          expect(User.find_by!(email: "test@example.com").authentication_code.expires_at).to be_future
        end
      end
    end
  end
end
