#!/usr/bin/env ruby
#
# File: wishlist.rb
# Author: eweb
# Copyright QStream, 2014-2018
# Contents:
#
# Date:          Author:  Comments:
# 24th Jun 2014  eweb     #0008 Download amazon wishlist
#  7th Apr 2018  eweb     #0007 rubocop
#

require 'nokogiri'
require 'open-uri'

def handle_row(row)
  item = {}
  row.children.each do |cell|
    clzz = cell.attribute('class')
    if clzz
      attr = clzz.value
      attr.sub!(/^g-/, '')
      next if attr == 'buttons'
      next if attr == 'requested'
      next if attr == 'received'
      next if attr == 'priority'
      txt = cell.text
      begin
        txt = text.strip
      rescue
        txt = txt.chars.collect { |ch| ch == "\xA3" ? "£" : ch }.join.strip
      end
      if attr == 'title'
        txt.lines.collect(&:strip).reject(&:empty?).each_with_index do |line, i|
          if i == 0
            item[attr] = line
          elsif line =~ /^Offered by (.+)/
            item['offered-by'] = $1
          elsif line =~ /^by (.+)/ || line =~ /^Starring (.+)/
            line = $1
            if line =~ /(.+) \((Audio CD|Paperback|Hardcover|MP3 Download|Blu-ray)\)/
              item['artist'] = $1
              item['type'] = $2
            else
              item['artist'] = line
            end
          else
            item["#{attr}-#{i}"] = line
          end
        end
      else
        item[attr] = txt
      end
    end
  end
  puts item.to_s
  #details = child.children[1]
  #price = child.children[3]
  #puts "#{details.inspect} #{price.inspect}"
end

def wishlist(listname)
  page = 1
  loop do
    url = "http://www.amazon.co.uk/registry/wishlist/#{listname}?layout=compact&page=#{page}"
    puts url

    html = open(url)
    doc = Nokogiri::HTML(html)
    #puts doc
    table = doc.xpath("//table[@class='a-bordered a-horizontal-stripes  g-compact-items']")
    #puts table.class
    #puts table.length
    #puts table.methods.to_s
    #puts table.inspect
    table.children.each do |child|
      #puts child.node_name
      if child.node_name == 'tbody'
        child = child.children.first
        if child.node_name == 'tr'
          handle_row(child)
        end
      elsif child.node_name == 'tr'
        handle_row(child)
      end
    end
    link = doc.xpath("//li[@class='a-last']")
    #puts link
    break if link.empty?
    page += 1
  end
end

mylist = '1S1WQYHWM4F41'

wishlist(mylist)
