require "rails_helper"

RSpec.describe ActiveStorage::Service::CloudflareR2Service do
  subject(:service) do
    described_class.new(
      bucket: "example",
      access_key_id: "access-key",
      secret_access_key: "secret-key",
      region: "auto",
      endpoint: "https://account.r2.cloudflarestorage.com",
      force_path_style: true,
      host: "https://cdn.example.com/"
    )
  end

  it "generates public-domain URLs without unsupported S3 ACLs" do
    expect(service).to be_public
    expect(service.upload_options).not_to include(:acl)
    expect(service.send(:public_url, "random/path/key")).to eq(
      "https://cdn.example.com/random/path/key"
    )
  end
end
