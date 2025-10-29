# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:parent).class_name("Collection").optional(true) }
  it { is_expected.to have_many(:children).class_name("Collection").with_foreign_key(:parent_id).dependent(:destroy) }
end
