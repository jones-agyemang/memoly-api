module SchemaLoader
  def self.load(schema_name)
    JSON.parse(
      Rails.root.join("spec/support/api/schemas/#{schema_name}.json").read,
      symbolize_names: true
    ).freeze
  end
end
