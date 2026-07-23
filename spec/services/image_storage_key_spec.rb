require "rails_helper"

RSpec.describe ImageStorageKey do
  describe ".generate" do
    it "creates three cryptographically random, non-semantic path components" do
      keys = Array.new(20) { described_class.generate }

      expect(keys.uniq.size).to eq(20)
      expect(keys).to all(match(/\A[0-9a-f]{32}\/[0-9a-f]{32}\/[0-9a-f]{48}\z/))
    end
  end

  it "is also used for derivative Active Storage blobs" do
    expect(ActiveStorage::Blob.generate_unique_secure_token).to match(
      %r{\A[0-9a-f]{32}/[0-9a-f]{32}/[0-9a-f]{48}\z}
    )
  end
end
