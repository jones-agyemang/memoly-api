require "rails_helper"

RSpec.describe MathDelimiters do
  describe "inline block text" do
    it "converts single-dollar math to use double-dollar delimiters" do
      text = "Equation $E=m^2$."

      converted_text = described_class.normalize_inline(text)

      expect(converted_text).to eq("Equation $$E=m^2$$.")
    end

    context "when text has double-dollar math delimiters" do
      it "should not convert it" do
        original_text = "Equation $$E=m^2$$."

        converted_text = described_class.normalize_inline(original_text)

        expect(converted_text).to eq(original_text)
      end
    end
  end
end
