class Collection < ApplicationRecord
  belongs_to :user
  belongs_to :parent, class_name: "Collection", optional: true
  has_many :children, class_name: "Collection", foreign_key: :parent_id, dependent: :destroy
  has_many :notes, dependent: :destroy

  validates :label, presence: true
  validate :validate_parent_scope

  before_save :update_path, :generate_slug
  after_save :refresh_descendant_paths, if: :saved_change_to_path?

  scope :top_level, -> { where(parent_id: nil) }

  DEFAULT_CATEGORY_LABEL = "Uncategorised"

  def default?
    label == DEFAULT_CATEGORY_LABEL
  end

  private

  def generate_slug
    self.slug = label.parameterize
  end

  def refresh_descendant_paths
    children.find_each(&:save!)
  end

  def validate_parent_scope
    return if parent_id.blank?

    if parent.nil?
      errors.add(:parent_id, :invalid)
      return
    end

    if parent.user_id != user_id
      errors.add(:parent_id, :invalid)
    end

    if id.present? && parent_id == id
      errors.add(:parent_id, :invalid)
    end

    if path.present? && parent.path.present? && parent.path.start_with?("#{path}.")
      errors.add(:parent_id, :invalid)
    end
  end

  def update_path
    node = label.parameterize.tr("-", "_")
    self.path = parent ? "#{parent.path}.#{node}" : node
  end
end
