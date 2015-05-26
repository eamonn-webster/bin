#!/usr/bin/env ruby
#
# File: getlyric.rb
# Author: eweb
# Copyright eweb, 2013-2015
# Contents:
#
# Date:          Author:  Comments:
#  5th Nov 2013  eweb     #0008 Maintenance
# 29th Nov 2013  eweb     #0008 Match divs over lines
# 24th Jun 2014  eweb     #0008 Reorg
# 20th Sep 2014  eweb     #0008 tidy html
# 25th Mar 2015  eweb     #0008 Apostrophies
# 26th May 2015  eweb     #0008 Translate entities
#
require 'nokogiri'
require 'open-uri'

def save_lyrics(lyric)
  lyric.gsub!( '&amp;', '&' )
  lyric.gsub!( '&lt;', '<' )
  lyric.gsub!( '&gt;', '>' )
  lyric.gsub!( /&#([0-9]+);/ ) { |hex| $1.to_i.chr }
  lyric.gsub!( /\n\n \n\n/, "\n\n" )
  lyric.gsub!( '<i>', '(' )
  lyric.gsub!( '</i>', ')' )
  puts lyric
  puts "**** Contains entities" if lyric[/&.+;/]

  IO.popen('pbcopy', 'w').puts lyric
end

def tidy(lyric)
  lyric = lyric.gsub /<div.+?<\/div>/m, ''
  lyric = lyric.gsub /<script.+?<\/script>/m, ''
  lyric = lyric.gsub /<!--.+?-->/m, ''
  lyric = lyric.gsub /<br>/, "\n"
  lyric = lyric.strip
end

def fetch_0
  artist = ARGV[0] if ARGV.length > 0
  song = ARGV[1..-1].join(' ') if ARGV.length > 1

  artist = artist.downcase
  song = song.downcase

  artist.gsub!(/ /, '_')
  artist.gsub!(/[^a-z0-9_]/, '')

  song.gsub!(/ /, '_')
  song.gsub!(/[^a-z0-9_]/, '')

  url = "http://www.lyricsmania.com/#{song}_lyrics_#{artist}.html"

  puts url

  begin
    doc = Nokogiri::HTML(open(url))
    lyric = doc.xpath( "id('songlyrics_h')" ).inner_html
    lyric = tidy(lyric)
    if lyric && lyric != ''
      save_lyrics(lyric)
      true
    end
  rescue Exception => e
    puts "#{e.class} #{e.message}"
  end
end

def fetch_1
  artist = ARGV[0].dup if ARGV.length > 0
  song = ARGV[1..-1].join(' ').dup if ARGV.length > 1

  artist.gsub!(/ /, '_')
  artist.gsub!("'", '%27')
  song.gsub!(/ /, '_')
  song.gsub!('?', '%3F')
  song.gsub!("'", '%27')

  url = "http://lyrics.wikia.com/#{artist}:#{song}"

  puts url
  begin
    doc = Nokogiri::HTML(open(url))
    lyric = doc.xpath( "//div[@class='lyricbox']" ).inner_html

    lyric = tidy(lyric)
    if lyric =~ /Unfortunately, we are not licensed to display the full lyrics/
      lyric = nil
    end
    if lyric =~ /Category:Instrumental/ && lyric =~ /TrebleClef/
      lyric = 'Instrumental'
    end
    if lyric && lyric != ''
      save_lyrics(lyric)
      true
    end
  rescue Exception => e
    puts "#{e.class} #{e.message}"
  end
end

def fetch_2
  artist = ARGV[0].dup if ARGV.length > 0
  song = ARGV[1..-1].join(' ').dup if ARGV.length > 1

  artist.gsub!(/ /, '_')
  song.gsub!(/ /, '_')
  song.gsub!('?', '%3F')

  artist = artist.downcase
  song = song.downcase

  url = "http://www.lyricsmode.com/lyrics/#{artist[0]}/#{artist}/#{song}.html"
  puts url
  begin
    doc = Nokogiri::HTML(open(url))

    lyric = doc.xpath( "id('songlyrics_h')" ).inner_html
    lyric = tidy(lyric)
    if lyric && lyric != ''
      save_lyrics(lyric)
      true
    end
  rescue Exception => e
    puts "#{e.class} #{e.message}"
  end
end

def fetch_3
  artist = ARGV[0].dup if ARGV.length > 0
  song = ARGV[1..-1].join(' ').dup if ARGV.length > 1

  artist.gsub!(/ /, '_')
  song.gsub!(/ /, '_')
  song.gsub!('?', '%3F')

  artist = artist.downcase
  song = song.downcase
  # strips leading 'The '
  artist.gsub!(/^The /, '')
  song.gsub!(/^The /, '')
  artist = artist.downcase
  song = song.downcase
  artist.gsub!(/[^a-z0-9]/, '')
  song.gsub!(/[^a-z0-9]/, '')
  url = "http://www.azlyrics.com/lyrics/#{artist}/#{song}.html"
  puts url

  begin
    doc = Nokogiri::HTML(open(url))

    lyric = doc.xpath( "id('songlyrics_h')" ).inner_html
    lyric = tidy(lyric)
    if lyric && lyric != ''
      save_lyrics(lyric)
      true
    end
  rescue Exception => e
    puts "#{e.class} #{e.message}"
  end

end

def fetch_4
  artist = ARGV[0].dup if ARGV.length > 0
  song = ARGV[1..-1].join(' ').dup if ARGV.length > 1
  artist = artist.downcase
  song = song.downcase
  artist.gsub!(/[^a-z0-9]+/, '-')
  song.gsub!(/[^a-z0-9]+/, '-')
  url = "http://www.lyricstime.com/#{artist}-#{song}-lyrics.html"
  puts url

  begin
    doc = Nokogiri::HTML(open(url))
    lyric = doc.xpath( "id('songlyrics')/p" ).inner_html
    lyric = tidy(lyric)
    if lyric && lyric != ''
      save_lyrics(lyric)
      true
    end
  rescue Exception => e
    puts e
  end
end

def fetch_5
  artist = ARGV[0].dup if ARGV.length > 0
  song = ARGV[1..-1].join(' ').dup if ARGV.length > 1
  artist = artist.downcase
  song = song.downcase
  artist.gsub!(/[^a-z0-9]+/, '')
  song.gsub!(/[^a-z0-9]+/, '-')
  url = "http://irishmusicdb.com/#{artist[0]}/#{artist}"
  puts url

  begin
    doc = Nokogiri::HTML(open(url))
    href = doc.css('a').detect{|a| a.attribute('href').to_s =~ /lyrics/}.attribute('href')
    url = "#{url}/#{href}"
    puts url
    doc = Nokogiri::HTML(open(url))
    if lyric && lyric != ''
      save_lyrics(lyric)
      true
    end
  rescue Exception => e
    puts e
  end
end

if ARGV.length < 2
# elsif fetch_0
elsif fetch_1
elsif fetch_2
elsif fetch_3
# elsif fetch_4
# elsif fetch_5
end

