# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateQuiz do
  context "missing access token" do
    xit "raises an error" do
      allow(ENV).to receive(:fetch) { nil }

      error_msg = "key not found: \"OPENAPI_ACCESS_TOKEN\""
      expect { described_class.call "" }.to raise_error(KeyError, error_msg)
    end
  end

  context "when access token is provided" do
    it "creates quiz" do
      VCR.use_cassette("open_ai_chat_completion") do
        topic = "Advanced Ruby"

        response_body = described_class.call topic

        expected_response_body = {
          questions: [
            {
              question: "What is a mixin in Ruby?",
              options: [ "A type of class", "A module included in a class", "A Ruby Gem", "A type of variable" ],
              answer: "A module included in a class",
              explanation: "Mixins in Ruby are modules that are included in a class to add functionality and share behavior among different classes."
            },
            {
              question: "How do you define a block in Ruby?",
              options: [ "Using brackets []", "Using curly braces {} or do...end", "Using parentheses ()", "Using angle brackets <>" ],
              answer: "Using curly braces {} or do...end",
              explanation: "Blocks in Ruby can be defined using either curly braces {} for single-line blocks or do...end for multi-line blocks."
            },
            {
              question: "What does the 'super' keyword do in Ruby?",
              options: [ "Calls the parent class method of the same name", "Creates a new class", "Instantiates an object", "Defines a new method" ],
              answer: "Calls the parent class method of the same name",
              explanation: "The 'super' keyword in Ruby is used to call the same method from the parent class, allowing you to leverage or extend the functionality of the inherited method."
            },
            {
              question: "What is a lambda in Ruby?",
              options: [ "A method with no name", "A type of array", "A type of loop", "An object representing a block of code" ],
              answer: "An object representing a block of code",
              explanation: "Lambdas in Ruby are objects representing blocks of code that can be stored in a variable and executed later. They are similar to Procs but have some differences in how they handle arguments and return statements."
            },
            {
              question: "How can you handle exceptions in Ruby?",
              options: [ "Using try-catch", "Using begin-rescue-end", "Using if-else", "Using switch-case" ],
              answer: "Using begin-rescue-end",
              explanation: "In Ruby, exceptions are handled using the begin-rescue-end block, which allows you to catch and handle errors gracefully."
            }
          ]
        }

        expect(response_body).to eq expected_response_body.as_json
      end
    end
  end
end
