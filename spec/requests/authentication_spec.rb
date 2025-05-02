# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentications', type: :request do
  describe 'POST /request' do
    context 'invalid attributes' do
      it 'does not create code' do
        post '/authentication/request-code', params: { email: '' }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'valid attributes' do
      context 'user exists' do
        before do
          @user = create(:user)
        end

        let(:valid_attributes) do
          { email: @user.email }
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
          ).with(hash_including params: { user_id: @user.id })
        end
      end

      context 'user does not exist' do
        it 'creates request code for new user' do
          post '/authentication/request-code', params: { email: 'test@example.com' }
        end
      end
    end
  end
end
