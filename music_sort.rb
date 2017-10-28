#!/usr/bin/env ruby

#
# File: music_sort.rb
# Author: eweb
# Copyright eweb, 2017-2017
# Contents:
#
# Date:          Author:  Comments:
# 28th Oct 2017  eweb     #0008 Checks sort terms
#

require 'nokogiri'

class MyDoc < Nokogiri::XML::SAX::Document
  def initialize
    @level = 0
    @count = 0
    @all_keys = []
    @albums = {}
  end
  def characters(chars)
    if @level == 3
      if @reading_key
        @key += chars
      else
        @key = @key.strip
        @value += chars
        if @key != ''
          @hash[@key] = @value.strip
        end
      end
    end
  end
  def start_element(name, attrs = [])
    if name == 'dict'
      @level += 1
      if @level == 3
        @hash = {}
        @key = ''
        @value = ''
      end
    elsif name == 'key'
      if @level == 3
        @key = ''
        @value = ''
        @reading_key = true
      end
    else
      if @level == 3
        @reading_key = false
        @value = ''
      end
      # puts "starting: #{name}"
    end
  end

  def remember_track(hash)
    artist = hash['Artist']
    album_artist = hash['Album Artist']
    album = hash['Album']
    name = hash['Name']
    location = hash['Location']
    track = hash['Track Number']
    disc = hash['Disc Number']
    album_key = "#{album_artist} - #{album}"
    track_key = "#{disc}.#{track}"
    @albums[album_key] ||= {}
    @albums[album_key][track_key] = hash
  end

  def process_albums
    @albums.each do |k, album|
      artists = album.map { |t, h| h['Artist'] }.compact.uniq
      album_artists = album.map { |t, h| h['Album Artist'] }.compact.uniq
      if artists.size == 1
        unless album_artists.empty?
          puts "#{k} #{artists[0]} but #{album_artists}"
        end
      end
    end
  end

  def end_element(name)
    if name == 'dict'
      if @level == 3
        sort_differs(@hash, 'Artist')
        sort_differs(@hash, 'Album')
        sort_differs(@hash, 'Name')
        sort_differs(@hash, 'Composer')
        # artist_and_album_artist(@hash)
        # puts @hash
        # remember_track(@hash)
        @all_keys += @hash.keys
        @all_keys.uniq!
        @hash = nil
      end
      @level -= 1
      if @level == 0
        puts "count #{@count}"
        # puts "keys: #{@all_keys}"
        # process_albums
      end
    else
      # puts "ending: #{name}"
    end
  end

  def artist_and_album_artist(hash)
    artist = hash['Artist']
    album_artist = hash['Album Artist']
    if artist && album_artist
      if artist == album_artist
        puts "#{artist} == #{album_artist} on #{hash['Album']}"
      else
        # puts "#{artist} != #{album_artist} on #{hash['Album']}"
      end
    end
  end

  def sort_differs(hash, field)
    value = hash[field]
    sort_value = hash["Sort #{field}"]
    if sort_value && sort_value == value
      if field == 'Album'
        puts "#{value} == #{sort_value}"
      elsif ['A House'].include?(value)
      else
        puts "#{value} == #{sort_value} on #{hash['Album']}"
      end
      @count += 1
    elsif sort_value && sort_value != value
      # elsif value == "#{hash['Album']} - #{hash['Artist']}"
      if value.sub(/\(?The /, '') == sort_value
      elsif value.sub('the ', '') == sort_value
      elsif value.sub('An ', '') == sort_value
      elsif value.sub('A ', '') == sort_value
      elsif value.sub('A ', '') == sort_value
      elsif value.sub(/^.../, '') == sort_value
      elsif value.sub(/^'/, '') == sort_value
      elsif value.sub(/^"/, '') == sort_value
      elsif ['Greatest Hits', 'The Real Thing', 'Yes'].include?(value)
      else
        puts "#{value} != #{sort_value}"
      end
    end
  end
end

# Create our parser
parser = Nokogiri::XML::SAX::Parser.new(MyDoc.new)

file = "#{ENV['HOME']}/Music/iTunes/iTunes Music Library.xml"
# Send some XML to the parser
# parser.parse(File.open(file))

File.open(file) do |fh|
  parser.parse(fh)
end
