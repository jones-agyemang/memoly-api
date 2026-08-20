# frozen_string_literal: true

module SourceParser
  class Core
    SYSTEM_MESSAGE = {
      role: "system",
      content: "You are a judicious, safety-conscious, professional-grade Educative content creator"
    }.freeze
    SOURCED_NOTES_SCHEMA = SchemaLoader.load("sourced_notes")
    REPORT_SOURCE_ERROR_SCHEMA = SchemaLoader.load("report_source_error")
    CLIENT_MUTEX = Mutex.new

    def initialize(source_intake, client: Core.client)
      @source_intake = source_intake
      @client = client
    end

    def self.call(source_intake, client: Core.client)
      new(source_intake, client:).parse
    end

    def self.client
      return @client if @client

      CLIENT_MUTEX.synchronize do
        @client ||= OpenAI::Client.new(
          access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"),
          log_errors: true
        )
      end
    end

    def parse
      response = client.chat(parameters: {
        model: "gpt-5.4",
        temperature: 0.7,
        messages: [ SYSTEM_MESSAGE, { role: "user", content: prompt } ],
        tools: tools_definition,
        tool_choice: "required", # confine returns to tools_definition
        parallel_tool_calls: false
      })
      arguments = response.dig("choices", 0, "message", "tool_calls", 0, "function", "arguments")
      JSON.parse(arguments)
    end

    private

    def prompt
      <<~PROMPT
        #{source_instructions}
        Organise all collections with an aptly labelled umbrella parent.#{' '}
        Group similar collection theme(s) tightly to avoid having too many loosely connected collections.#{' '}
        Use sub-categories for a natural hierarchical ordering of ideas.#{' '}
        Return collections as an object keyed by collection label.#{' '}
        For each collection, include parent_label as null for top-level collections or#{' '}
        the parent collection label for sub-categories, position as a zero-based sibling order, and notes as an array of note strings.#{' '}
        Use markdown formatting for notes.#{' '}
        Provide title as a header for each note.#{' '}
        Wrap code blocks in triple backticks with language tag and inline code with single backticks.#{' '}
        Where helpful/viable include illustrations using mermaid. Wrap mermaid as blocks with triple backticks and "mermaid" as the language tag.
      PROMPT
    end

    def source_instructions
      raise NotImplementedError, "#{self.class} must implement #source_instructions"
    end

    def tools_definition
      [
        # {
        #   type: "function",
        #   function: {
        #     name: "report_source_error",
        #     parameters: REPORT_SOURCE_ERROR_SCHEMA
        #   }
        # },
        {
          type: "function",
          function: {
            name: "source_notes",
            parameters: SOURCED_NOTES_SCHEMA
          }
        }
      ]
    end

    attr_reader :client, :source_intake
  end
end
