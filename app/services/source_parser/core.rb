# frozen_string_literal: true

module SourceParser
  class Core
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
          access_token: ENV.fetch("OPENAI_ACCESS_TOKEN") { ENV.fetch("OPENAI_API_KEY") },
          log_errors: true
        )
      end
    end

    def parse
      response = client.responses.create(parameters: {
        model: "gpt-5.4",
        temperature: 0.7,
        input: response_input,
        tools: responses_tools_definition,
        tool_choice: "required",
        parallel_tool_calls: false
      })

      tool_call = response.fetch("output").find do |item|
        item["type"] == "function_call" && item["name"] == "source_notes"
      end
      raise JSON::ParserError, "The model did not return a source_notes tool call" unless tool_call

      JSON.parse(tool_call.fetch("arguments"))
    end

    private

    def meta_prompt
      <<~META_PROMPT
        # Identity
        You are a judicious, safety-conscious, professional-grade Educative content creator.#{' '}
        In addition you infer and assume the role of an expert of the content you receive.#{' '}

        # Instructions
        ## Organisation
        Organise all collections with an aptly labelled umbrella parent collection.#{' '}
        Group similar collection theme(s) tightly to avoid having too many loosely connected collections.#{' '}
        Use sub-categories for a natural hierarchical ordering of ideas.#{' '}
        For each collection, include parent_label as null for top-level collections or#{' '}
        the parent collection label for sub-categories, position as a zero-based sibling order, and notes as an array of note strings.#{' '}
        If the given material provides sufficient information, dig deeper and return multiple sub-categories of the parent category.#{' '}
        Use markdown formatting for notes.#{' '}
        Provide a title as a header for each note.#{' '}
        Wrap code blocks in triple backticks with language tag and inline code with single backticks.#{' '}
        Where helpful/viable include illustrations using mermaid. Wrap mermaid as blocks with triple backticks and "mermaid" as the language tag.
        Use web search to research the subject thoroughly when external sources would improve accuracy, currency, or completeness.#{' '}

        ## Output
        Return collections as an object keyed by collection label.#{' '}
        Always finish by calling the source_notes function with the completed notes; never return the final result as plain text.
      META_PROMPT
    end

    def response_input
      [
        {
          role: "system",
          content: [ { type: "input_text", text: meta_prompt } ]
        },
        {
          role: "user",
          content: [ { type: "input_text", text: source_instructions } ]
        }
      ]
    end

    def prompt
      <<~PROMPT
        #{source_instructions}
      PROMPT
    end

    def source_instructions
      raise NotImplementedError, "#{self.class} must implement #source_instructions"
    end

    def tools_definition
      [
        # {
        #   type: "function",
        #   name: "report_source_error",
        #   parameters: REPORT_SOURCE_ERROR_SCHEMA
        # },
        {
          type: "function",
          name: "source_notes",
          parameters: SOURCED_NOTES_SCHEMA
        }
      ]
    end

    def responses_tools_definition
      [
        { type: "web_search", search_context_size: "high" },
        *tools_definition
      ]
    end

    attr_reader :client, :source_intake
  end
end
