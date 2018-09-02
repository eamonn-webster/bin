#!/usr/bin/env ruby

#
# File: import_music.rb
# Author: eweb
# Copyright eweb, 2018-2018
# Contents:
#
# Date:          Author:  Comments:
#  2nd Apr 2018  eweb     #0008 adding music
# 19th Jul 2018  eweb     #0008 iTunes on Transcend drive
#  2nd Sep 2018  eweb     #0008 sleep between moves
#

itunes_dir = "#{ENV['HOME']}/Music/iTunes"
itunes_dir = "/Volumes/Transcend/Music/iTunes"
own_dir = "#{ENV['HOME']}/Music/Own"
downloads = "#{ENV['HOME']}/Downloads"

def shell(cmd)
  puts cmd
  system(cmd)
end

Dir.chdir("#{own_dir}/temp") do
  shell("mv #{downloads}/*\\ -\\ *.zip .")
  shell("open *.zip")
  gets
  shell("mv *.zip ..")
  Dir["*"].each do |f|
    shell("mv \"#{f}\" #{itunes_dir}/iTunes\\ Media/Automatically\\ Add\\ to\\ iTunes.localized/")
    sleep(5)
  end
end
