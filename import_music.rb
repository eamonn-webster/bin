#!/usr/bin/env ruby

#
# File: import_music.rb
# Author: eweb
# Copyright eweb, 2018-2020
# Contents:
#
# Date:          Author:  Comments:
#  2nd Apr 2018  eweb     #0008 adding music
# 19th Jul 2018  eweb     #0008 iTunes on Transcend drive
#  2nd Sep 2018  eweb     #0008 sleep between moves
#  1st Feb 2019  eweb     #0008 iTunes not on Transcend
#  7th Nov 2019  eweb     #0008 use unzip
# 23rd Jul 2020  eweb     #0008 Music has moved
#  5th Sep 2020  eweb     #0008 output music items
#  5th Sep 2020  eweb     #0007 turned onto a class
#

class ImportMusic
  def itunes_dir
    @itunes_dir ||= determine_itunes_dir
  end

  def determine_itunes_dir
    dir = '/Volumes/Transcend/Music/iTunes'
    return dir if Dir.exist?(dir)

    "#{ENV['HOME']}/Music/iTunes"
  end

  def own_dir
    "#{ENV['HOME']}/Music/Own"
  end

  def downloads
    "#{ENV['HOME']}/Downloads"
  end

  def shell(cmd)
    puts cmd
    system(cmd)
  end

  def import
    Dir.chdir("#{own_dir}/temp") do
      puts Dir["#{downloads}/*\\ -\\ *.zip"]
      shell("mv #{downloads}/*\\ -\\ *.zip .")
      Dir['*.zip'].map do |z|
        b = File.basename(z, '.zip')
        shell("unzip \"#{z}\" -d \"#{b}\"")
        add_accounts_data(z, b)
      end
      shell('mv *.zip ..')
      Dir['*'].each do |f|
        shell("mv \"#{f}\" #{itunes_dir}/iTunes\\ Media/Automatically\\ Add\\ to\\ Music.localized/")
        sleep(5)
      end
    end

    output_accounts_data
  end

  def output_accounts_data
    return unless accounts_data.size > 1

    puts accounts_data
  end

  def accounts_data
    @accounts_data ||= ['I 6']
  end

  def add_accounts_data(z, dir)
    b = File.basename(z)
    return unless b =~ /(.+) - (.+).zip/

    accounts_data << music_item($1, $2, dir)
  end

  def music_item(artist, album, dir)
    c = song_count(dir)
    amount = if c == 0
               '0.00~'
             else
               format('%0.02f=', 0.08 * c)
             end
    %(M "#{album}" "#{artist}" "mp3va" "" #{todays_date} 0000-00-00 0000-00-00 0000-00-00 "MP3" "Dowloaded" #{amount} "mp3va")
  end

  def todays_date
    Time.now.strftime('%Y-%m-%d')
  end

  def song_count(dir)
    glob = Dir["#{dir}/*.mp3"]
    # puts "#{dir}: #{glob.size}"
    # puts glob
    glob.size
  end
end

if $PROGRAM_NAME == __FILE__
  ImportMusic.new.import
end
