# frozen_string_literal: true

require 'comandor'

module Machine
  class Commands
    extend Comandor
    COMMANDS = %i[DEFINE CREATE ADVANCE DECIDE STATS].freeze

    def perform(text)
      process text
    end

    private

    def process(text)
      l = 1
      text.collect! do |line|
        command, value, *params = line.split(/\s+/)
        unless COMMANDS.include? command.to_sym
          return error(:command, "Wrong Command '#{command}' on line #{l}, available commands #{COMMANDS.join(', ')}")
        end
        l += 1
        [command, value] + params
      end
    end
  end
end
