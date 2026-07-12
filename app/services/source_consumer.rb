class SourceConsumer
  def self.call(source_intake, arguments)
    user_id = source_intake.user_id

    parsed_raw_source = arguments.fetch(:collections, [])

    parsed_raw_source.each do |label, attributes|
      if attributes[:parent_label]
        parent = Collection.find_or_create_by!(label: attributes[:parent_label])
        collection = Collection.create!(label:, user_id:, position: attributes[:position], parent_id: parent.id)
      else
        collection = Collection.create!(label:, user_id:, position: attributes[:position])
      end

      attributes.fetch(:notes, []).each do |content|
        collection.notes.create(raw_content: content)
      end
    end
  end
end
