#!/usr/bin/env ruby
#
# File: synchmusic.rb
# Author: eweb
# Copyright eweb, 2012-2021
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
#  3rd Jun 2019  eweb     #0008 skip if source not found
#  2nd May 2020  eweb     #0008 including Running
# 15th Jun 2020  eweb     #0008 exclude movies
# 31st Aug 2020  eweb     #0008 use brewed rsync
# 31st Aug 2020  eweb     #0008 specify utf-8-mac
# 31st Aug 2020  eweb     #0008 exclude Automatically Added
# 29th Oct 2020  eweb     #0008 add colour
#  4th Mar 2021  eweb     #0008 check dir before synching
# 20th Oct 2021  eweb     #0008 bare repos
#

RED = "\033[0;31m"
GREEN = "\033[0;32m"
NORM = "\033[0m"

class String
  def in_red
    "#{RED}#{self}#{NORM}"
  end

  def in_green
    "#{GREEN}#{self}#{NORM}"
  end
end

def main
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

  src = if Dir.exist?('/Volumes/Transcend')
          '/Volumes/Transcend/Music/iTunes'
        else
          '/Users/eweb/Music/iTunes'
        end

  dst = "/Volumes/#{drive}/iTunes"

  rsync = '/usr/local/bin/rsync'

  if @back
    cmd = "#{rsync} --iconv=utf-8-mac,utf-8-mac -rtvi --exclude .DS_Store #{dst}/ #{src}"
    puts cmd
    system(cmd)
    cmd.gsub!('iTunes', 'Own')
    puts cmd
    system(cmd)
  else
    puts 'iTunes'.in_green
    cmd = "#{rsync} --iconv=utf-8-mac,utf-8-mac -rtvi --exclude .DS_Store --exclude 'Mobile Applications' --exclude 'Automatically Add to *.localized' --exclude 'Movies' --delete-during #{src}/ #{dst}"
    puts cmd
    system(cmd)

    puts 'Own'.in_green
    src = '/Users/eweb/Music/Own'
    dst = "/Volumes/#{drive}/Own"
    cmd = "#{rsync} --iconv=utf-8-mac,utf-8-mac -rtvi --exclude .DS_Store #{src}/ #{dst}"
    puts cmd
    system(cmd)

    src = '/Users/eweb/Pictures/Photos Library.photoslibrary/Masters'
    dst = "/Volumes/#{drive}/Pictures/Masters"
    if Dir.exist?(src)
      puts 'Photos'.in_green
      cmd = "#{rsync} --iconv=utf-8-mac,utf-8-mac -rtvi --exclude .DS_Store --delete-during '#{src}/' '#{dst}'"
      puts cmd
      system(cmd)
    else
      puts 'Photos'.in_red
    end

    bare_repos = %w[tbw]
    bare_repos.each do |repo|
      src = "/Users/eweb/projects/#{repo}.git"
      dst = "/Volumes/#{drive}/projects/#{repo}.git"
      if Dir.exist?(src)
        puts repo.in_green
        cmd = "#{rsync} --iconv=utf-8-mac,utf-8-mac -rtvi --exclude .DS_Store --delete-during '#{src}/' '#{dst}'"
        puts cmd
        system(cmd)
      else
        puts repo.in_red
      end
    end

    src = '/Users/eweb/projects/acc'
    dst = "/Volumes/#{drive}/projects/acc"
    %w[ruby Accounts Shopping].each do |dir|
      puts dir.in_green
      cmd = "#{rsync} --iconv=utf-8-mac,utf-8-mac -rtvi --exclude .DS_Store '#{src}/#{dir}/tmp/metric_fu/' '#{dst}/#{dir}/tmp/metric_fu'"
      puts cmd
      system(cmd)
    end

    dirs = [["/Volumes/#{drive}/projects/acc", 'git@bitbucket.org:eamoon/acc.git'],
            ["/Volumes/#{drive}/projects/Running", 'git@bitbucket.org:eamoon/running.git'],
            ["/Volumes/#{drive}/accounts/master", 'git@bitbucket.org:eamoon/data.git'],
            ["/Volumes/#{drive}/bin", 'git@bitbucket.org:eamoon/bin.git'],
            ["/Volumes/#{drive}/projects/metric_fu", 'https://github.com/eamonn-webster/metric_fu.git'],
            ["/Volumes/#{drive}/projects/flog", 'https://github.com/eamonn-webster/flog.git'],
            # ["/Volumes/#{drive}/projects/wbt", "/Users/eweb/projects/wbt.git"]
            ["/Volumes/#{drive}/projects/simway", 'git@bitbucket.org:eamoon/simway.git'],
            ["/Volumes/#{drive}/projects/bacon-expect", 'https://github.com/eamonn-webster/bacon-expect.git']]

    dirs.each do |dir, remote|
      puts dir.in_green
      if Dir.exist?(dir)
        Dir.chdir(dir) do
          puts 'git pull'
          system('git pull')
        end
      else
        puts("git clone #{remote} #{dir}")
        system("git clone #{remote} #{dir}")
      end
    end
  end
end

def transfer_fu
  transfer_fu_inner('/Volumes/eweb/projects/acc', '/Users/eweb/projects/acc', %w[ruby Accounts Shopping])
  transfer_fu_inner('/Volumes/eweb/projects/Running', '/Users/eweb/projects/Running', %w[Running])
end

def transfer_fu_inner(src, dst, folders)
  folders.each do |dir|
    cmd = "#{rsync} --iconv=utf-8-mac,utf-8-mac -rtvi --exclude .DS_Store '#{src}/#{dir}/tmp/metric_fu/' '#{dst}/#{dir}/tmp/metric_fu'"
    puts cmd
    system(cmd)
  end
end

def get_music
  drive = 'iomega1'
  # src = "/Users/eweb/Music/iTunes"
  # src = "/Volumes/Transcend/Music/iTunes"
  # dst = "/Volumes/#{drive}/iTunes"

  dst = '/Users/eweb/Music/iTunes'
  src = "/Volumes/#{drive}/iTunes"
  cmd = "#{rsync} --iconv=utf-8-mac,utf-8-mac -rtvi --exclude .DS_Store --exclude 'Mobile Applications' --exclude 'Not Added' --delete-during #{src}/ #{dst}"
  puts cmd
  # system(cmd)
end

if $PROGRAM_NAME == __FILE__
  main
end
