#!/usr/bin/env ruby

#
# File: import_music.rb
# Author: eweb
# Copyright eweb, 2018-2018
# Contents:
#
# Date:          Author:  Comments:
#  2nd Apr 2018  eweb     #0008 adding music
#

own_dir = "#{ENV['HOME']}/Music/Own"
downloads = "#{ENV['HOME']}/Downloads"

def shell(cmd)
  puts cmd
  system(cmd)
end

Dir.chdir("#{own_dir}/temp") do
  shell("mv #{downloads}/*\\ -\\ *.zip .")
  shell("open *.zip")
  shell("mv *.zip ..")
  shell("mv * ../../iTunes/iTunes\\ Media/Automatically\\ Add\\ to\\ iTunes.localized/")
end
