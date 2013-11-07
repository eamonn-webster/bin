#!/usr/bin/env ruby
#
# File: synchmusic.rb
# Author: eweb
# Copyright eweb, 2012-2013
# Contents:
#
# Date:          Author:  Comments:
# 10th Sep 2012  eweb     #0008 Detect backup volume
# 14th Aug 2013  eweb     #0008 Convert to ruby
#  7th Nov 2013  eweb     #0008 Sync back
#

if Dir.exist?('/Volumes/IOMEGA0')
  drive = 'IOMEGA0'
elsif Dir.exist?('/Volumes/iomega1')
  drive = 'iomega1'
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
  cmd = "rsync -rtvi --delete-during #{dst}/ #{src}"
  puts cmd
  system( cmd )
else
  cmd = "rsync -rtvi --delete-during #{src}/ #{dst}"
  puts cmd
  system( cmd )

  dirs = ["/Volumes/#{drive}/projects/wacc",
          "/Volumes/#{drive}/accounts/java"]

  dirs.each do |dir|
    Dir.chdir(dir) do
      puts dir
      puts "git fetch --all"
      system( "git fetch --all")
    end
  end

end
#cmd = "rsync -rtvi #{src}/ /Volumes/Macintosh\ HD-1/#{src}"


