desc "Create first class application"
namespace :setup do
  task application: :environment do
    application = Doorkeeper::Application.find_or_initialize_by(
      name: "Memoly Web Client"
    )

    application.update(
      redirect_uri: "https://www.memoly.io/oauth/callback",
      confidential: true,
      scopes: "users"
    )
  end
end
