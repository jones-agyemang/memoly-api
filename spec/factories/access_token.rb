FactoryBot.define do
  factory :access_token, class: "Doorkeeper::AccessToken" do
    transient do
      user { create(:user) }
    end

    application do
      Doorkeeper::Application.find_or_create_by!(name: "Memoly Web Client") do |app|
        app.redirect_uri = "https://www.memoly.io/oauth/callback"
        app.confidential = true
        app.scopes = "users"
      end
    end

    resource_owner_id { user.id }
    token { SecureRandom.hex(32) }
    expires_in { 1.week.to_i }
    scopes { "user" }
  end
end
