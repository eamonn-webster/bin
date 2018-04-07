#!/usr/bin/env ruby

#
# File: pullissue.rb
# Author: eweb
# Copyright eweb, 2018-2018
# Contents:
#
# Date:          Author:  Comments:
#  7th Apr 2018  eweb     #0007 rubocop
#
issue = ARGV[0]
head = ARGV[1]
base = ARGV[2]

head ||= `git rev-parse --abbrev-ref HEAD`
head = head.strip
base ||= 'master'

if ARGV.empty?
  puts "usage #{$PROGRAM_NAME} issue [head:#{head}] [base:#{base}]"
  puts "hub pull-request -i <issue> -b <base> -h qstream:<head>"
else
  #cmd = "curl -ss --user eamonn-webster --request POST --data '{\"issue\": \"#{issue}\", \"head\": \"#{head}\", \"base\": \"#{base}\"}' https://api.github.com/repos/qstream/spaced-ed/pulls"
  cmd = "hub pull-request -i #{issue} -b #{base} -h qstream:#{head}"
  puts cmd
  puts `#{cmd}`
end
