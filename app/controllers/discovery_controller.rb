class DiscoveryController < ApplicationController
  helper_method :filtered_notes_for, :children_for

  def index
    @normalized_query = params[:q].to_s.strip.downcase
    @visible_collections = visible_collections
    @children_map = @visible_collections.group_by(&:parent_id)
    @top_level_collections = @visible_collections.select { |collection| collection.parent_id.nil? }
  end

  private

  def visible_collections
    collections = Collection.includes(:user, :parent, :notes).where(public: true)
    visible = collections.select(&:publicly_visible?)

    return visible if @normalized_query.blank?

    filter_collections(visible)
  end

  def filter_collections(collections)
    children_map = collections.group_by(&:parent_id)

    collections.select do |collection|
      collection_matches?(collection, children_map)
    end
  end

  def collection_matches?(collection, children_map)
    direct_match = collection.label.to_s.downcase.include?(@normalized_query) || notes_match?(collection.notes)

    direct_match || (children_map[collection.id] || []).any? do |child|
      collection_matches?(child, children_map)
    end
  end

  def notes_match?(notes)
    notes.any? do |note|
      next false unless note.public?

      [ note.raw_content, note.source ].compact.any? do |field|
        field.to_s.downcase.include?(@normalized_query)
      end
    end
  end

  def filtered_notes_for(collection)
    notes = collection.public_notes
    return notes if @normalized_query.blank?

    notes.select do |note|
      [ note.raw_content, note.source ].compact.any? do |field|
        field.to_s.downcase.include?(@normalized_query)
      end
    end
  end

  def children_for(collection)
    @children_map[collection.id] || []
  end
end
