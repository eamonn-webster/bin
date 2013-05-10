#! /usr/bin/env ruby
require 'nokogiri'
require 'open-uri'

artist = ARGV[0] if ARGV.length > 0
song = ARGV[1..-1].join(' ') if ARGV.length > 1

artist ||= 'Therapy?'
song ||= 'Disgracelands'

def save_lyrics(lyric)
  lyric.gsub!( '&amp;', '&' )
  lyric.gsub!( '&lt;', '<' )
  lyric.gsub!( '&gt;', '>' )
  puts lyric
  puts "**** Contains entities" if lyric[/&.+;/]

  IO.popen('pbcopy', 'w').puts lyric
end


artist = artist.downcase
song = song.downcase

artist.gsub!(/ /, '_')
artist.gsub!(/[^a-z0-9_]/, '')

song.gsub!(/ /, '_')
song.gsub!(/[^a-z0-9_]/, '')

url = "http://www.lyricsmania.com/#{song}_lyrics_#{artist}.html"

puts url

doc = Nokogiri::HTML(open(url))

lyric = doc.xpath( "id('songlyrics_h')" ).inner_html.gsub /<br>/, ''
lyric = lyric.strip

if lyric && lyric != ''
  save_lyrics(lyric)
else

  artist = ARGV[0].dup if ARGV.length > 0
  song = ARGV[1..-1].join(' ').dup if ARGV.length > 1

  artist.gsub!(/ /, '_')
  song.gsub!(/ /, '_')
  song.gsub!('?', '%3F')

  url = "http://lyrics.wikia.com/#{artist}:#{song}"

  puts url

  begin
    doc = Nokogiri::HTML(open(url))
    lyric = doc.xpath( "//div[@class='lyricbox']" ).inner_html

    lyric = lyric.gsub /<div.+<\/div>/, ''
    lyric = lyric.gsub /<!--.+-->/m, ''
    lyric = lyric.gsub /<br>/, "\n"

    lyric = lyric.strip
    if lyric =~ /Unfortunately, we are not licensed to display the full lyrics/
      lyric = nil
    end

  rescue Exception => e
    puts e
  end

  if lyric && lyric != ''
    save_lyrics(lyric)
  else
    artist = artist.downcase
    song = song.downcase
    url = "http://www.lyricsmode.com/lyrics/#{artist[0]}/#{artist}/#{song}.html"
    puts url

    begin
      doc = Nokogiri::HTML(open(url))

      lyric = doc.xpath( "id('songlyrics_h')" ).inner_html.gsub /<br>/, ''
      lyric = lyric.strip
    rescue Exception => e
      puts e
    end

    if lyric && lyric != ''
      save_lyrics(lyric)
    else
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

        lyric = doc.xpath( "id('songlyrics_h')" ).inner_html.gsub /<br>/, ''
        lyric = lyric.strip
      rescue Exception => e
        puts e
      end

      if lyric && lyric != ''
        save_lyrics(lyric)
      else
      end
    end
  end

end

