# frozen_string_literal: true

module Helpers
  def file_in(num = 1)
    "./spec/fixtures/input#{num}.txt"
  end

  def file_in_wrong
    './spec/fixtures/input_wrong.txt'
  end

  def file_out(num = '')
    "./spec/fixtures/output#{num}.txt"
  end
end
