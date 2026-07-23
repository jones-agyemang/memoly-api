class ImageStorageKey
  def self.generate
    [
      SecureRandom.hex(16),
      SecureRandom.hex(16),
      SecureRandom.hex(24)
    ].join("/")
  end
end
