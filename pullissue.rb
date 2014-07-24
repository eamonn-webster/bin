#!/usr/bin/env ruby
issue = ARGV[0]
head = ARGV[1]
base = ARGV[2]

head = %x{git rev-parse --abbrev-ref HEAD} unless head
head = head.strip
base ||= 'edge'

if ARGV.empty?
  puts "usage #{$0} issue [head:#{head}] [base:#{base}]"
  puts "hub pull-request -i <issue> -b <base> -h qstream:<head>"
else
  #cmd = "curl -ss --user eamonn-webster --request POST --data '{\"issue\": \"#{issue}\", \"head\": \"#{head}\", \"base\": \"#{base}\"}' https://api.github.com/repos/qstream/spaced-ed/pulls"
  cmd = "hub pull-request -i #{issue} -b #{base} -h qstream:#{head}"
  puts cmd
  puts %x{#{cmd}}
end
