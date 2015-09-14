#!/usr/bin/env ruby

#
# File: song356.rb
# Author: eweb
# Copyright Qstream, 2015-2015
# Contents:
#
# Date:          Author:  Comments:
#  7th Sep 2015  eweb     #0008 Tagging songs from songs365
#

require 'taglib'

files = []
options = {}
ARGV.each_with_index do |arg, i|
  if arg && arg[0] == '-'
    if arg == '--album'
      options[:album] = ARGV[i+1]
    elsif arg == '--artist'
      options[:artist] = ARGV[i+1]
    elsif arg == '--year'
      options[:year] = ARGV[i+1].to_i
    end
    ARGV[i] = nil
    ARGV[i+1] = nil
  end
end

@update = true

# Load a file
files = ARGV.compact.sort_by {|filename| File.mtime(filename) }
files.each_with_index do |arg, i|
  options[:track] = i + 1
  # options[:tracks] = files.size
  if arg =~ /([^\/]+) - (.+)_\(song365.cc\).mp3/
    options[:artist] = $1
    options[:title] = $2
  end
  TagLib::FileRef.open(arg) do |fileref|
    unless fileref.null?
      tag = fileref.tag
      puts "#{arg} #{tag.artist} #{tag.album} #{tag.year} #{tag.track} #{tag.title}"
      if @update
        options.each do |k, v|
          tag.send("#{k}=", v)
        end
        puts "#{arg} #{tag.artist} #{tag.album} #{tag.year} #{tag.track} #{tag.title}"
        fileref.save
      end
    end
  end  # File is automatically closed at block end
end
