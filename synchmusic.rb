#!/usr/bin/env ruby
#
# File: synchmusic.rb
# Author: eweb
# Copyright eweb, 2012-2015
# Contents:
#
# Date:          Author:  Comments:
# 10th Sep 2012  eweb     #0008 Detect backup volume
# 14th Aug 2013  eweb     #0008 Convert to ruby
#  7th Nov 2013  eweb     #0008 Sync back
# 29th Nov 2013  eweb     #0008 Don't copy backwards
# 24th Jun 2014  eweb     #0008 Change from java to master
# 25th Mar 2015  eweb     #0008 Backup own music
#

if Dir.exist?('/Volumes/IOMEGA0')
  drive = 'IOMEGA0'
elsif Dir.exist?('/Volumes/iomega1')
  drive = 'iomega1'
else
  puts 'Removeable drive not found'
  exit
end

src = "/Users/eweb/Music/iTunes"
dst = "/Volumes/#{drive}/iTunes"

# rsyncflags = 'rt'
# r recursive
# l preserve symlinks
# p preserve permissions
# t preserve times
# g preserve group
# o preserve owner
# D same as --devices --specials

if @back
  cmd = "rsync -rtvi  #{dst}/ #{src}"
  puts cmd
  system( cmd )
  cmd.gsub!('iTunes', 'Own')
  puts cmd
  system( cmd )
else
  cmd = "rsync -rtvi --delete-during #{src}/ #{dst}"
  puts cmd
  system( cmd )
  cmd.gsub!('iTunes', 'Own')
  puts cmd
  system( cmd )

  dirs = ["/Volumes/#{drive}/projects/wacc",
          "/Volumes/#{drive}/accounts/master"]

  dirs.each do |dir|
    Dir.chdir(dir) do
      puts dir
      puts "git fetch --all"
      system( "git fetch --all")
    end
  end

end

