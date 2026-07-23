require "rails_helper"

RSpec.describe ImageAttachable do
  it "configures the same three proportional variants for notes and collections" do
    [ Note, Collection ].each do |model|
      reflection = model.attachment_reflections.fetch("images")

      expect(reflection.named_variants.keys).to contain_exactly(:large, :medium, :small)
    end
  end
end
