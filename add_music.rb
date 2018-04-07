#!/usr/bin/env ruby

#
# File: add_music.rb
# Author: eweb
# Copyright eweb, 2016-2018
# Contents:
#
# Date:          Author:  Comments:
# 29th Dec 2016  eweb     #0008 when adding music from mp3va
# 14th Jan 2017  eweb     #0008 unzip into folder
#  7th Apr 2018  eweb     #0007 rubocop
#

downloads = "#{ENV['HOME']}/Downloads"
music_own = "#{ENV['HOME']}/Music/Own"
auto_add = "#{ENV['HOME']}/Music/iTunes/iTunes Media/Automatically Add to iTunes.localized"

def run(cmd)
  puts cmd
  system(cmd)
end

Dir["#{downloads}/* - *.zip"].map do |zip_path|
  zip = File.basename(zip_path)
  name = zip.sub('.zip', '')
  run(%(mv "#{downloads}/#{zip}" #{music_own}))
  run(%(unzip "#{music_own}/#{zip}" -d "#{music_own}/temp/#{name}"))
  run(%(mv "#{music_own}/temp/#{name}" "#{auto_add}"))
  break
end
