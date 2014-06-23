#! /usr/bin/env ruby
#
# File: download_log.rb
# Author: eweb
# Copyright qstream, 2013-2014
# Contents:
#
# Date:          Author:  Comments:
#  5th Nov 2013  eweb     #0008 Down load log from logentries
# 24th Jun 2014  eweb     #0008 Need date
#

require 'net/http'
require 'json'
require 'date'

account_key = '3ffd5292-c855-43ee-985e-4dcacb9c0415'
host_name = 'Heroku'

require 'getoptlong'

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--yesterday', '-y', GetoptLong::NO_ARGUMENT ],
  [ '--date', GetoptLong::REQUIRED_ARGUMENT ]
)

opts.each do |opt, arg|
  case opt
  when '--help'
    puts "usage: #{$0} [options] app"
    puts " --yesterday"
    puts " --date=date"
    puts " where app is the name of the app e.g. qs-alpha or qs-bleedin"
    exit
  when '--yesterday'
    @yesterday = true
  when '--date'
    @date = Time.parse(arg)
  end
end

log_name = ARGV[0] || 'qs-alpha'

# account_key = 'eda87a6e-a876-4e81-9271-ee664f339de4' if log_name == 'qs-bleedin'

url = "http://api.logentries.com/#{account_key}/hosts/#{host_name}/#{log_name}"
uri = URI.parse(url)

puts url
response = Net::HTTP.get_response(uri)
data = JSON.parse(response.body)
log_key = data['key']

#url = "https://api.logentries.com/#{account_key}/hosts/#{host_name}/#{log_id}/"
url = "https://api.logentries.com/#{account_key}/hosts/#{host_name}/#{log_key}/"

t0 = @date || Time.new
t0 = Time.local(t0.year, t0.month, t0.day)
t0 = t0 - (60 * 60 * 24) if @yesterday
t1 = t0 + (60 * 60 * 24)
#t1 = t0 + (60 * 60)

log_file = "#{log_name}-#{t0.strftime('%Y-%m-%d')}.log"

cmd = "curl '#{url}?start=#{t0.to_i * 1000}&end=#{t1.to_i * 1000}&compress=gzip'"

puts "Fetching... #{log_file}"
`#{cmd} > #{log_file}.gz`

puts 'Expanding...'
`gzip -df #{log_file}.gz`

puts "Filtering... filtered-#{log_file}"
%x{filter_log.rb #{log_file} filtered-#{log_file}}
