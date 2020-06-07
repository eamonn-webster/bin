#!/usr/bin/env ruby
#
# File: rem-duplicate-music.rb
# Author: eweb
# Copyright eweb, 2013-2018
# Contents:
#
# Date:          Author:  Comments:
#  5th Nov 2013  eweb     #0008 Clearing out windows music files
#  7th Apr 2018  eweb     #0007 rubocop
#

itunes_home = "#{ENV['HOME']}/Music/iTunes/iTunes Media/Music"
iomega_home = "#{ENV['HOME']}/iomega0/Documents and Settings/eweb/My Documents/My Music"

Dir.new(iomega_home).each do |artist|
  next if artist =~ /^\./
  next unless File.directory?("#{iomega_home}/#{artist}")

  Dir.new("#{iomega_home}/#{artist}").each do |album|
    next if album =~ /^\./

    orig = album
    album = album.gsub(/ Disc [1-9]$/, '')
    album = album.gsub(/ \[.+\]$/, '')
    if File.exist?("#{itunes_home}/#{artist}/#{album}")
      #puts "removing #{orig}"
      cmd = "rm -rf \"#{iomega_home}/#{artist}/#{orig}\""
      puts cmd
      `#{cmd}`
    else
      puts "#{artist}/#{orig}"
    end
  end
end
