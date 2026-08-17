module SourceParser
  class Core
    def initialize(source_intake)
      @source_intake = source_intake
    end

    def self.call(source_intake)
      new(source_intake).parse
    end

    private

    def tools_definition
      [
        {
          type: "function",
          function: {
            name: "create_notes",
            parameters: {
              type: "object",
              properties: {
                collections: {
                  type: "object",
                  minProperties: 1,
                  additionalProperties: {
                    type: "object",
                    properties: {
                      parent_label: { type: [ "string", "null" ] },
                      position: { type: "integer", minimum: 0 },
                      notes: {
                        type: "array",
                        minItems: 1,
                        items: { type: "string" }
                      }
                    },
                    required: [ "parent_label", "position", "notes" ]
                  }
                }
              },
              required: [ "collections" ]
            }
          }
        }
      ]
    end

    attr_reader :source_intake
  end
end
