# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe "Setup::Application", type: :task do
  let(:task) { Rake::Task['setup:application'] }
  before(:all) do
    Rails.application.load_tasks
  end
  after { task.reenable }

  context "when application does not exist" do
    it "creates a new application" do
      expect do
        task.invoke
      end.to change(Doorkeeper::Application, :count).by(1)
    end
  end

  context "when application already exists" do
    it "does not re-create it" do
      Doorkeeper::Application.destroy_all

      Doorkeeper::Application.create!(
        name: "Memoly Web Client",
        redirect_uri: "https://localhost:3000/oauth/callback",
        confidential: [ true, false ].sample,
        scopes: [ "users", "documents" ].sample
      )

      expect do
        task.invoke
      end.not_to change(Doorkeeper::Application, :count)
    end
  end
end
