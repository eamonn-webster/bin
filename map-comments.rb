#!/usr/bin/env ruby
#
# File: map-comments.rb
# Author: eweb
# Copyright eweb, 2012-2018
# Contents:
#
# Date:          Author:  Comments:
#  8th Sep 2012  eweb     #1507 Remap comments
# 24th Oct 2012  eweb     #0008 filter-branch to remap comments
#  7th Apr 2018  eweb     #0007 rubocop
#
# This script remaps issue ids. When I started using issue ids I started at 5000 because I wanted to leave room
# so that at some stage in the future I could assign ids to the previous issues. As it turns out 1000 would have been enough.
# Well the time has come. The idea is that I will use git's filter-branch command to rewrite history.
# I need to process files and commit messages. In each case I need to subtract 4000 from each issue number greater than 5000.
# This is easy enough as I haven't yet reached 6000.
# so the command is s/#5([0-9][0-9][0-9])/#1\1/g
#
# git filter-branch --tree-filter 'find . -type f -exec map-comments.rb {} \;' --msg-filter 'map-comments.rb'
# git filter-branch --tree-filter 'find . -type f -exec map-comments.rb {} \;' --msg-filter 'map-comments.rb' HEAD
#
# utf-16 is more hassle than it's worth to fix to just ignore...

# read from file or standard in
# write to file or standard out

require 'fileutils'

verbose = false
input = nil
output = nil
inplace = false
@extension = nil

puts "#{__FILE__} #{ARGV.join(' ')}" if verbose

infile = ARGV[0]
outfile = ARGV[1]

skip_extensions = %w[ico bak tmp old cur lib reg vsscc jar png]

skip_folders = %w[thoughtworks/xstream simplericity/macify]

@cpp_extensions = %w[cpp h rc]

if infile == '-' || infile.nil? || infile.empty?
  input = STDIN
elsif infile
  if infile =~ /\.([^.]+)$/
    @extension = $1
  end

  if skip_extensions.include? @extension
    exit
  end
  skip_folders.each do |f|
    exit if infile[f]
  end
  input = File.open(infile)
end

if outfile == '-'
  output = STDOUT
elsif outfile
  output = File.open(outfile, 'w')
elsif infile && infile != '-'
  # puts "will update #{infile} in place"
  output = File.open("#{infile}.tmp", 'w')
  inplace = true
else
  output = STDOUT
end

def test_equal(expected, actual)
  raise "oops #{expected} != #{actual}" unless expected == actual
end

def remap_id(line, file, lineno)
  puts "#{file}:#{lineno} #{line.encoding} - #{line}" unless line.encoding.to_s == 'UTF-8'
  # puts "#{file}:#{lineno} #{line.encoding} - INVALID - #{line}" unless line.valid_encoding?
  if !line.valid_encoding?
    line.force_encoding('cp1252')
    #puts "#{file}:#{lineno} #{line[0].ord.to_s(16)} == 0xff && #{line[1].ord.to_s(16)} == 0xfe"
    if lineno == 1 && line[0].ord == 0xff && line[1].ord == 0xfe
      puts "#{file}:#{lineno} found utf-16 bom"
      line.force_encoding('UTF-16')
      return line
    else
      new_line = ''
      new_line.encode('cp1252')
      line.chars do |ch|
        if ch.ord == 0x91 || ch.ord == 0x92
          # convert smart quotes to apostrophe
          #puts "#{file}:#{lineno} #{ch.ord.to_s(16)}"
          new_line << '\''
        elsif ch.ord == 0xa9
          #puts "#{file}:#{lineno} #{ch.ord.to_s(16)}"
          new_line << '(c)'
        elsif ch.ord == 0xbd || # ½
          ch.ord == 0xa3 || # £
          ch.ord == 0xac || # ¬
          ch.ord == 0xfe # þ
          #puts "#{file}:#{lineno} #{ch.ord.to_s(16)}"
          new_line << ch
        elsif ch.ord >= 0x80
          puts "#{file}:#{lineno} #{ch.ord.to_s(16)}"
          new_line << ch
        else
          new_line << ch
        end
      end
      if !@cpp_extensions.include? @extension
        line = new_line.encode('UTF-8')
      end
      if line != new_line
        puts "#{file}:#{lineno} < #{line}" unless line.valid_encoding?
        line = new_line
        puts "#{file}:#{lineno} > #{line}" unless line.valid_encoding?
      end
    end
  end
  line.gsub(/#5([0-9][0-9][0-9])(?![0-9])/, '#1\1')
end

# line = " #555555; "
# test_equal( line, remap_id( line ) )
#
# line = " #5545; "
# test_equal( " #1545; ", remap_id( line ) )

changed = false

input.each do |line|
  new_line = remap_id(line, infile, input.lineno)
  if line != new_line
    #puts "changed"
    changed = true
  end
  output.puts new_line
end
if output != STDOUT
  output.close
end
if input != STDIN
  input.close
end

if inplace
  if changed
    puts "updating file #{infile}" if verbose
    if File.file? "#{infile}.old"
      FileUtils.rm "#{infile}.old"
    end
    atime = File.atime infile
    mtime = File.mtime infile
    FileUtils.mv infile, "#{infile}.old"
    FileUtils.mv "#{infile}.tmp", infile
    File.utime atime, mtime, infile
    FileUtils.rm "#{infile}.old"
  else
    FileUtils.rm "#{infile}.tmp"
  end
end
