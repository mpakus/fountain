# frozen_string_literal: true

require_relative './machine/commands'
require_relative './machine/process'

module Machine
  class << self
    def run(file_in = 'input.txt', file_out = 'output.txt')
      write file_out, process(commands(read(file_in)))
    end

    private

    def read(file)
      File.readlines(file)
    end

    def commands(text)
      Machine::Commands.perform(text).result
    end

    def process(commands)
      Machine::Process.perform(commands).result
    end

    def write(file, output)
      File.write(file, output.join("\n"))
    end
  end
end
