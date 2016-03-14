#!/usr/bin/env ruby

#
# File: split-log.rb
# Author: eweb
# Copyright eweb, 2016-2016
# Contents:
#
# Date:          Author:  Comments:
# 14th Mar 2016  eweb     #0008 split a log file
#

file = ARGV[0]
dir = File.dirname(file)
base = File.basename(file, ".*")
ext = File.extname(file)
dir = '' if dir == '.'
dir = dir + '/' unless dir.empty?

File.open(file) do |input|
  first_line = input.readline
  input.rewind
  if first_line =~ /^([0-9]{4}-[0-9]{2}-[0-9]{2})/
    date = $1
  end
  output = File.open("#{dir}#{base}-#{date}#{ext}", "w")
  input.each_line do |line|
    if line =~ /^([0-9]{4}-[0-9]{2}-[0-9]{2})/
      if $1 != date
        date = $1
        output.close
        output = File.open("#{dir}#{base}-#{date}#{ext}", "w")
      end
    end
    output.puts(line)
  end
  output.close
end
