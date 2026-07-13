class SourceConsumer
  def self.call(source_intake, arguments)
    user_id = source_intake.user_id
    arguments = ActiveSupport::HashWithIndifferentAccess.new(arguments)

    parsed_raw_source = arguments.fetch(:collections, [])

    parsed_raw_source.each do |label, attributes|
      base_attrs = { label:, user_id:, position: attributes[:position], public: true }

      if attributes[:parent_label]
        parent = Collection.find_or_create_by!(label: attributes[:parent_label], user_id: user_id)
        collection = Collection.create!(base_attrs.merge(parent_id: parent.id))
      else
        collection = Collection.create!(base_attrs)
      end

      attributes.fetch(:notes, []).reverse.each do |content|
        collection.notes.create(raw_content: content, source: source_intake.source)
      end
    end
  end
end
