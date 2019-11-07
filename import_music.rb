#!/usr/bin/env ruby

#
# File: import_music.rb
# Author: eweb
# Copyright eweb, 2018-2019
# Contents:
#
# Date:          Author:  Comments:
#  2nd Apr 2018  eweb     #0008 adding music
# 19th Jul 2018  eweb     #0008 iTunes on Transcend drive
#  2nd Sep 2018  eweb     #0008 sleep between moves
#  1st Feb 2019  eweb     #0008 iTunes not on Transcend
#  7th Nov 2019  eweb     #0008 use unzip
#

itunes_dir = "/Volumes/Transcend/Music/iTunes"
if !Dir.exist?(itunes_dir)
  itunes_dir = "#{ENV['HOME']}/Music/iTunes"
end

own_dir = "#{ENV['HOME']}/Music/Own"
downloads = "#{ENV['HOME']}/Downloads"

def shell(cmd)
  puts cmd
  system(cmd)
end

Dir.chdir("#{own_dir}/temp") do
  puts Dir["#{downloads}/*\\ -\\ *.zip"]
  shell("mv #{downloads}/*\\ -\\ *.zip .")
  Dir["*.zip"].map do |z|
    b = File.basename(z, ".zip")
    shell("unzip \"#{z}\" -d \"#{b}\"")
  end
  shell("mv *.zip ..")
  Dir["*"].each do |f|
    shell("mv \"#{f}\" #{itunes_dir}/iTunes\\ Media/Automatically\\ Add\\ to\\ iTunes.localized/")
    sleep(5)
  end
end
