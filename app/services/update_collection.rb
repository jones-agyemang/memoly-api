# frozen_string_literal: true

class UpdateCollection
  def self.call(collection, attributes)
    collection.user.with_lock do
      collection.reload
      source_parent_id = collection.parent_id
      collection.assign_attributes(attributes)
      requested_position = collection.position

      if requested_position.nil?
        collection.errors.add(:position, :invalid)
        raise ActiveRecord::RecordInvalid, collection
      end

      source_siblings = collection.user.collections.where(parent_id: source_parent_id).where.not(id: collection.id)
      target_siblings = if source_parent_id == collection.parent_id
        source_siblings
      else
        collection.user.collections.where(parent_id: collection.parent_id).where.not(id: collection.id)
      end

      ordered_target = Collection.ordered_siblings(target_siblings)
      insertion_index = (requested_position - 1).clamp(0, ordered_target.length)
      ordered_target.insert(insertion_index, collection)
      collection.position = insertion_index + 1
      # Validate the new parent and refresh descendant paths using normal callbacks.
      collection.save! if collection.changed?

      groups = [ ordered_target ]
      groups << Collection.ordered_siblings(source_siblings) if source_parent_id != collection.parent_id
      groups.each do |siblings|
        siblings.each_with_index do |sibling, index|
          sibling.position = index + 1
          sibling.save! if sibling.changed?
        end
      end
    end
    true
  rescue ActiveRecord::RecordInvalid => error
    collection.errors.merge!(error.record.errors) unless error.record.equal?(collection)
    false
  end
end
