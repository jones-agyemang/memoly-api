class Collection < ApplicationRecord
  belongs_to :user
  belongs_to :parent, class_name: "Collection", optional: true
  has_many :children, class_name: "Collection", foreign_key: :parent_id, dependent: :destroy
  has_many :notes

  validates :label, presence: true

  before_save :update_path, :generate_slug

  scope :top_level, -> { where(parent_id: nil) }

  DEFAULT_CATEGORY_LABEL = "Uncategorised"

  def default?
    label == DEFAULT_CATEGORY_LABEL
  end

  private

  def generate_slug
    self.slug = label.parameterize
  end

  def update_path
    node = label.parameterize.tr("-", "_")
    self.path = parent ? "#{parent.path}.#{node}" : node
  end
end
