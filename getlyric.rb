#!/usr/bin/env ruby
#
# File: getlyric.rb
# Author: eweb
# Copyright eweb, 2013-2021
# Contents:
#
# Date:          Author:  Comments:
#  5th Nov 2013  eweb     #0008 Maintenance
# 29th Nov 2013  eweb     #0008 Match divs over lines
# 24th Jun 2014  eweb     #0008 Reorg
# 20th Sep 2014  eweb     #0008 tidy html
# 25th Mar 2015  eweb     #0008 Apostrophies
# 26th May 2015  eweb     #0008 Translate entities
#  7th Sep 2015  eweb     #0008 encoding
# 16th Dec 2015  eweb     #0008 handle commas
# 29th Dec 2016  eweb     #0008 handle exclamation marks
# 28th Oct 2017  eweb     #0008 tidy up
#  7th Apr 2018  eweb     #0007 rubocop
# 19th Jul 2018  eweb     #0008 fetch from genius
# 25th Nov 2018  eweb     #0008 return inner_text
# 25th Nov 2018  eweb     #0008 dryed up
#  6th Dec 2018  eweb     #0008 return inner_html for wikia
# 18th Aug 2019  eweb     #0008 wikia moved to fandom
# 29th Nov 2020  eweb     #0008 genius first try 3 times
#  9th May 2021  eweb     #0007 URI.open
#  4th Jun 2021  eweb     #0008 trim hyphens
#
require 'nokogiri'
require 'open-uri'
require 'cgi'

def save_lyrics(lyric)
  lyric.gsub!('&amp;', '&')
  lyric.gsub!('&lt;', '<')
  lyric.gsub!('&gt;', '>')
  lyric.gsub!(/&#([0-9]+);/) { $1.to_i.chr }
  lyric.gsub!(/\n\n \n\n/, "\n\n")
  lyric.gsub!('<i>', '(')
  lyric.gsub!('</i>', ')')
  puts lyric
  puts '**** Contains entities' if lyric[/&.+;/]

  IO.popen('pbcopy', 'w').puts lyric
end

def tidy(lyric)
  lyric = lyric.gsub(/<div.+?<\/div>/m, '')
  lyric = lyric.gsub(/<script.+?<\/script>/m, '')
  lyric = lyric.gsub(/<!--.+?-->/m, '')
  lyric = lyric.gsub(/<br>\n/, "\n")
  lyric = lyric.gsub(/<br>/, "\n")
  lyric = lyric.gsub(/<p>/, '')
  lyric = lyric.gsub(/<\/p>/, "\n")
  lyric.strip
end

def process_lyric(lyric)
  lyric = tidy(lyric)
  if lyric && lyric != ''
    save_lyrics(lyric)
    true
  end
end

def fetch_lyricsmania
  artist = ARGV[0] if ARGV.any?
  song = ARGV[1..].join(' ') if ARGV.length > 1

  artist = artist.downcase
  song = song.downcase

  artist.tr!(' ', '_')
  artist.gsub!(/[^a-z0-9_]/, '')

  song.tr!(' ', '_')
  song.gsub!(/[^a-z0-9_]/, '')

  url = "http://www.lyricsmania.com/#{song}_lyrics_#{artist}.html"

  puts url

  begin
    doc = Nokogiri::HTML(URI.open(url))
    lyric = doc.xpath("id('songlyrics_h')").inner_text
    process_lyric(lyric)
  rescue StandardError => e
    puts "#{e.class} #{e.message}"
  end
end

def fetch_lyrics_wikia
  artist = ARGV[0].dup if ARGV.any?
  song = ARGV[1..].join(' ').dup if ARGV.length > 1

  artist.tr!(' ', '_')
  song.tr!(' ', '_')
  artist = CGI.escape(artist)
  song = CGI.escape(song)

  url = "https://lyrics.fandom.com/#{artist}:#{song}"

  puts url
  begin
    doc = Nokogiri::HTML(URI.open(url))
    lyric = doc.xpath("//div[@class='lyricbox']").inner_html

    if lyric =~ /Unfortunately, we are not licensed to display the full lyrics/
      lyric = nil
    end
    if lyric =~ /Category:Instrumental/ && lyric =~ /TrebleClef/
      lyric = 'Instrumental'
    end
    process_lyric(lyric)
  rescue StandardError => e
    puts "#{e.class} #{e.message}"
  end
end

def fetch_lyricsmode
  artist = ARGV[0].dup if ARGV.any?
  song = ARGV[1..].join(' ').dup if ARGV.length > 1

  artist.tr!(' ', '_')
  song.tr!(' ', '_')
  song.gsub!('?', '%3F')

  artist = artist.downcase
  song = song.downcase

  url = "https://www.lyricsmode.com/lyrics/#{artist[0]}/#{artist}/#{song}.html"
  puts url
  begin
    doc = Nokogiri::HTML(URI.open(url))

    lyric = doc.xpath("id('songlyrics_h')").inner_text
    process_lyric(lyric)
  rescue StandardError => e
    puts "#{e.class} #{e.message}"
  end
end

def fetch_azlyrics
  artist = ARGV[0].dup if ARGV.any?
  song = ARGV[1..].join(' ').dup if ARGV.length > 1

  artist.tr!(' ', '_')
  song.tr!(' ', '_')
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
  url = "https://www.azlyrics.com/lyrics/#{artist}/#{song}.html"
  puts url

  begin
    doc = Nokogiri::HTML(URI.open(url))

    lyric = doc.xpath("id('songlyrics_h')").inner_text
    process_lyric(lyric)
  rescue StandardError => e
    puts "#{e.class} #{e.message}"
  end
end

def fetch_lyricstime
  artist = ARGV[0].dup if ARGV.any?
  song = ARGV[1..].join(' ').dup if ARGV.length > 1
  artist = artist.downcase
  song = song.downcase
  artist.gsub!(/[^a-z0-9]+/, '-')
  song.gsub!(/[^a-z0-9]+/, '-')
  url = "http://www.lyricstime.com/#{artist}-#{song}-lyrics.html"
  puts url

  begin
    doc = Nokogiri::HTML(URI.open(url))
    lyric = doc.xpath("id('songlyrics')/p").inner_html
    process_lyric(lyric)
  rescue StandardError => e
    puts e
  end
end

def fetch_irishmusicdb
  artist = ARGV[0].dup if ARGV.any?
  song = ARGV[1..].join(' ').dup if ARGV.length > 1
  artist = artist.downcase
  song = song.downcase
  artist.gsub!(/[^a-z0-9]+/, '')
  song.gsub!(/[^a-z0-9]+/, '-')
  url = "http://irishmusicdb.com/#{artist[0]}/#{artist}"
  puts url

  begin
    doc = Nokogiri::HTML(URI.open(url))
    href = doc.css('a').detect { |a| a.attribute('href').to_s =~ /lyrics/ }.attribute('href')
    url = "#{url}/#{href}"
    puts url
    doc = Nokogiri::HTML(URI.open(url))
    lyric = doc.xpath("id('songlyrics')/p").inner_text
    process_lyric(lyric)
  rescue StandardError => e
    puts e
  end
end

# https://genius.com/Champion-jack-dupree-im-tired-of-moanin-lyrics
# https://genius.com/champion-jack-dupree-im-tired-of-moaning-lyrics
def fetch_genius
  artist = ARGV[0].dup if ARGV.any?
  song = ARGV[1..].join(' ').dup if ARGV.length > 1
  artist = artist.downcase
  song = song.downcase
  artist.gsub!(/[^a-z0-9]+/, '-')
  artist[0] = artist[0].upcase
  song.delete!("'")
  song.gsub!(/[^a-z0-9]+/, '-')
  song.gsub!(/^-/, '')
  song.gsub!(/-$/, '')
  url = "https://genius.com/#{artist}-#{song}-lyrics"
  puts url

  begin
    3.times.detect do
      doc = Nokogiri::HTML(URI.open(url))
      lyric = doc.xpath("//div[@class='lyrics']").inner_text
      if process_lyric(lyric)
        true
      else
        puts url
        false
      end
    end
  rescue StandardError => e
    puts e
  end
end

if ARGV.length < 2
elsif fetch_genius
elsif fetch_lyrics_wikia
elsif fetch_lyricsmode
elsif fetch_azlyrics
end
