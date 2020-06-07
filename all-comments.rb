#!/usr/bin/env ruby
#
# File: all-comments.rb
# Author: eweb
# Copyright eweb, 2012-2018
# Contents: Extract all history comments from file(s)
#
# Date:          Author:  Comments:
#  8th Sep 2012  eweb     #0008 Gather all history from files
#  7th Apr 2018  eweb     #0007 rubocop
#
class Comment
  attr_accessor :number, :date, :author, :text, :file

  @with_ids = {}
  @missing_ids = {}

  def self.add(args = {})
    n = new(args)
    if n.number == 0
      if @missing_ids.key? n.text
        #puts "already have this one"
      elsif !n.text.empty?
        @missing_ids[n.text] = n
      end
    elsif @with_ids.key? n.text
    #puts "already have this one"
    elsif !n.text.empty?
      @with_ids[n.text] = n
    end
  end

  def self.display_missing
    @missing_ids.each_value do |v|
      puts v.format
    end
  end

  def self.display_with
    @with_ids.each_value do |v|
      puts v.format
    end
  end

  def initialize(args = {})
    args[:number] ||= 0
    args[:text] ||= ''
    args[:date] ||= ''
    args[:author] ||= ''

    t = args[:text]
    if t =~ /^#([0-9]+)\s+(.+)/
      args[:number] = $1.to_i
      args[:text] = $2
    elsif t =~ /^#([0-9]+),\s+(.+)/
      args[:number] = $1.to_i
      args[:text] = $2
    elsif t =~ /^#\?+\s+(.+)/
      args[:number] = 0
      args[:text] = $1
    end
    t = args[:text]
    t.gsub!(/^- /, '')
    if t =~ /^Lint/
      args[:number] = 7
    end
    if t =~ /^.+ =?=> .+/
      args[:number] = 7
    end
    args.each do |k, v|
      send("#{k}=", v)
    end
  end

  def format
    "#{@date.rjust(13)}  #{@author.ljust(7)}  ##{format('%04d', @number)} #{@text}"
  end

  def to_s
    "#{@number} #{@date} #{@author} #{@text} #{@file}"
  end
end

def process_file(file, input)
  history = false
  multiline = nil
  closing = nil
  prefix = nil

  date = nil
  author = nil

  input.each do |line|
    next unless line.valid_encoding?

    line.chomp!
    if multiline.nil?
      if line =~ /^#/
        multiline = false
        prefix = '#'
      elsif line =~ /\/*/
        multiline = true
        closing = '*/'
      else
        puts "Error unrecognised first line #{line}"
      end
    end

    if line =~ /Date:\s+Author:\s+Comment/
      history = true
      next
    end

    if multiline
      if line == closing
        history = false
      end
    elsif multiline == false
      if history && !line.start_with?(prefix)
        history = false
      end
    end

    if history
      if multiline == false
        line = line[(prefix.length)..]
      end
      if line =~ /^\s+([0-9]{1,2}(?:st|nd|rd|th) [A-Z][a-z][a-z] [0-9]{4})\s+([^ ]+)\s+(.+)/
        date = $1
        author = $2
        text = $3
        Comment.add(date: date, author: author, text: text, file: file)
        #puts line
      elsif line =~ /^\s+([0-9]{1,2}(?:st|nd|rd|th) [A-Z][a-z][a-z] [0-9]{4})\s+([^ ]+)\s*/
        date = $1
        author = $2
        text = $3
        Comment.add(date: date, author: author, text: text, file: file)
        #puts line
      elsif line =~ /^\s+(.+)/
        text = $1
        Comment.add(date: date, author: author, text: text, file: file)
      end
    end
  end
end

if ARGV.empty?
  process_file '-', STDIN
else
  ARGV.each do |arg|
    next if arg.start_with?('-')
    next if File.directory? arg

    # puts arg
    process_file arg, File.open(arg)
  end
end

Comment.display_missing
