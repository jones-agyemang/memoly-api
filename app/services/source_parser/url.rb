# frozen_string_literal: true

module SourceParser
  class Url < Core
    private

    def source_instructions
      "Use the contents of the following URL(#{source_intake.source}) to generate notes categorised by collection. "
    end
  end
end
