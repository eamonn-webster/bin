#!/usr/bin/env ruby

# frozen_string_literal: true

#
# File: sort_yaml.rb
# Author: eweb
# Copyright eweb, 2021-2021
# Contents:
#
# Date:          Author:  Comments:
# 17th Nov 2021  eweb     #0008 sort metric_du data for comparison
#

require 'yaml'

data = YAML.load_file(ARGV[0])

def sort_it(x)
  case x
  when Hash
    (x.keys - [:rspec, :path]).sort { |x, y| compare_them(x, y) }.map { |k| [k, sort_it(x[k])] }.to_h
  when Array
    x.map { |a| sort_it(a) }.sort { |x, y| compare_them(x, y) }.map
  else
    x
  end
end

def compare_them(x, y)
  if x.is_a?(Hash) && y.is_a?(Hash)
    if x.key?(:name) && y.key?(:name)
      return compare_them(x[:name], y[:name])
    end
  end
  x.to_s <=> y.to_s
end

File.write(ARGV[0] + 'out', sort_it(data).to_yaml)
