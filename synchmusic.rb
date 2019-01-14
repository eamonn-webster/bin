#!/usr/bin/env ruby
#
# File: synchmusic.rb
# Author: eweb
# Copyright eweb, 2012-2019
# Contents:
#
# Date:          Author:  Comments:
# 10th Sep 2012  eweb     #0008 Detect backup volume
# 14th Aug 2013  eweb     #0008 Convert to ruby
#  7th Nov 2013  eweb     #0008 Sync back
# 29th Nov 2013  eweb     #0008 Don't copy backwards
# 24th Jun 2014  eweb     #0008 Change from java to master
# 25th Mar 2015  eweb     #0008 Backup own music
#  7th Sep 2015  eweb     #0008 synch bin and exclude mobile apps
# 25th Sep 2016  eweb     #0008 remote for first run
# 14th Jan 2017  eweb     #0008 copy photos
# 28th Oct 2017  eweb     #0008 other repos
# 18th Dec 2017  eweb     #0008 exclude Not Added
#  7th Apr 2018  eweb     #0007 rubocop
# 25th Apr 2018  eweb     #0008 music now on transcend card
# 19th Jul 2018  eweb     #0008 copy metric_fu data
# 19th Jul 2018  eweb     #0008 pull rather than fetch
# 19th Jul 2018  eweb     #0008 wacc to acc
#  2nd Sep 2018  eweb     #0008 exclude .DS_Store
# 14th Jan 2019  eweb     #0008 transferring to new machine
#

if Dir.exist?('/Volumes/IOMEGA0')
  drive = 'IOMEGA0'
elsif Dir.exist?('/Volumes/iomega1')
  drive = 'iomega1'
else
  puts 'Removeable drive not found'
  exit
end

# rsyncflags = 'rt'
# r recursive
# l preserve symlinks
# p preserve permissions
# t preserve times
# g preserve group
# o preserve owner
# D same as --devices --specials

if Dir.exist?('/Volumes/Transcend')
  src = "/Volumes/Transcend/Music/iTunes"
else
  src = "/Users/eweb/Music/iTunes"
end

if @back
  dst = "/Volumes/#{drive}/iTunes"

  cmd = "rsync -rtvi --exclude .DS_Store #{dst}/ #{src}"
  puts cmd
  system(cmd)
  cmd.gsub!('iTunes', 'Own')
  puts cmd
  system(cmd)
else
  dst = "/Volumes/#{drive}/iTunes"
  cmd = "rsync -rtvi --exclude .DS_Store --exclude 'Mobile Applications' --exclude 'Not Added' --delete-during #{src}/ #{dst}"
  puts cmd
  system(cmd)

  src = "/Users/eweb/Music/Own"
  dst = "/Volumes/#{drive}/Own"
  cmd = "rsync -rtvi --exclude .DS_Store #{src}/ #{dst}"
  puts cmd
  system(cmd)

  src = "/Users/eweb/Pictures/Photos Library.photoslibrary/Masters"
  dst = "/Volumes/#{drive}/Pictures/Masters"
  cmd = "rsync -rtvi --exclude .DS_Store --delete-during '#{src}/' '#{dst}'"
  puts cmd
  system(cmd)

  src = "/Users/eweb/projects/wbt.git"
  dst = "/Volumes/#{drive}/projects/wbt.git"
  cmd = "rsync -rtvi --exclude .DS_Store --delete-during '#{src}/' '#{dst}'"
  puts cmd
  system(cmd)

  src = "/Users/eweb/projects/acc"
  dst = "/Volumes/#{drive}/projects/acc"
  %w[ruby Accounts Shopping].each do |dir|
    cmd = "rsync -rtvi --exclude .DS_Store '#{src}/#{dir}/tmp/metric_fu/' '#{dst}/#{dir}/tmp/metric_fu'"
    puts cmd
    system(cmd)
  end

  dirs = [["/Volumes/#{drive}/projects/acc", "git@bitbucket.org:eamoon/acc.git"],
          ["/Volumes/#{drive}/accounts/master", "git@bitbucket.org:eamoon/data.git"],
          ["/Volumes/#{drive}/bin", "git@bitbucket.org:eamoon/bin.git"],
          ["/Volumes/#{drive}/projects/metric_fu", "https://github.com/eamonn-webster/metric_fu.git"],
          ["/Volumes/#{drive}/projects/flog", "https://github.com/eamonn-webster/flog.git"],
          # ["/Volumes/#{drive}/projects/wbt", "/Users/eweb/projects/wbt.git"]
          ["/Volumes/#{drive}/projects/simway", "git@bitbucket.org:eamoon/simway.git"],
          ["/Volumes/#{drive}/projects/bacon-expect", "https://github.com/eamonn-webster/bacon-expect.git"]]

  dirs.each do |dir, remote|
    puts dir
    if Dir.exist?(dir)
      Dir.chdir(dir) do
        puts "git pull"
        system("git pull")
      end
    else
      puts("git clone #{remote} #{dir}")
      system("git clone #{remote} #{dir}")
    end
  end
end

def transfer_fu
  src = "/Volumes/eweb/projects/acc"
  dst = "/Users/eweb/projects/acc"

  %w[ruby Accounts Shopping].each do |dir|
    cmd = "rsync -rtvi --exclude .DS_Store '#{src}/#{dir}/tmp/metric_fu/' '#{dst}/#{dir}/tmp/metric_fu'"
    puts cmd
    system(cmd)
  end
end

def get_music
  drive = 'iomega1'
  src = "/Users/eweb/Music/iTunes"
  src = "/Volumes/Transcend/Music/iTunes"
  dst = "/Volumes/#{drive}/iTunes"

  dst = "/Users/eweb/Music/iTunes"
  src = "/Volumes/#{drive}/iTunes"
  cmd = "rsync -rtvi --exclude .DS_Store --exclude 'Mobile Applications' --exclude 'Not Added' --delete-during #{src}/ #{dst}"
  puts cmd
  # system(cmd)
end
