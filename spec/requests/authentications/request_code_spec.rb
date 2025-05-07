# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentications', type: :request do
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

        it "sends requested code to user's email" do
          expect do
            post '/authentication/request-code', params: valid_attributes
          end.to have_enqueued_mail(
            SendRequestedCodeMailer, :send_authentication_code
          ).with(hash_including params: { user_id: user.id })
        end

        context "user have been previously issued with a code" do
          it "sends new request code to user's email" do
            create(:authentication_code, user:)

            expect do
              post '/authentication/request-code', params: valid_attributes
            end.to have_enqueued_mail(
              SendRequestedCodeMailer, :send_authentication_code
            ).with(hash_including params: { user_id: user.id })
          end
        end
      end

      context 'user does not exist' do
        it 'creates request code for new user' do
          expect do
            post '/authentication/request-code', params: { email: 'test@example.com' }
          end.to have_enqueued_mail(
            SendRequestedCodeMailer, :send_authentication_code
          )
        end
      end
    end
  end
end
