#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './src/machine'

puts 'Reading from input.txt file...'
Machine.run
puts 'Writing into output.txt file...'
