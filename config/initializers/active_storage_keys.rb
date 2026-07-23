module RandomHierarchicalActiveStorageKeys
  def generate_unique_secure_token(length: nil)
    ImageStorageKey.generate
  end
end

Rails.application.config.to_prepare do
  singleton_class = ActiveStorage::Blob.singleton_class
  singleton_class.prepend(RandomHierarchicalActiveStorageKeys) unless singleton_class < RandomHierarchicalActiveStorageKeys
end
