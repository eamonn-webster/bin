#!/usr/bin/env ruby
#
# File: backup-git.rb
# Author: eweb
# Copyright eweb, 2012-2012
# Contents:
#
# Date:          Author:  Comments:
# 24th Oct 2012  eweb     #0008 Port to ruby
#

curDir = Dir.pwd
#puts "curDir: #{curDir}"

root = nil
if curDir =~ /^(.):/
  root = "$1:/"
elsif curDir =~ /^\/cygdrive\/(.)/
  root = "/cygdrive/$1/"
elsif RUBY_PLATFORM =~ /darwin/
  root = ''
elsif curDir =~ /^\/(.)/
  root = "/$1/"
end

# puts "root: #{root}"

prefix = File.basename(curDir)
mnp = nil
if File.exists? "#{root}topclass/oracle/topclass/sources/buildno.h"
  prefix = 'tc'
  File.open("#{root}topclass/oracle/topclass/sources/buildno.h").each do |line|
    if line =~ /#define THREEDIGITVER _TEXT\("([0-9]+)"\)/
      $mnp = $1
      last
    end
  end
elsif File.exists? "#{root}java/acc/src/org/eweb/cpp/AppInfo.java"
  #prefix = 'wacc'
  m = nil
  n = nil
  p = nil
  File.open("#{root}java/acc/src/org/eweb/cpp/AppInfo.java").each do |line|
    if line =~ /public static final int MAJOR = ([0-9]+);/
      m = $1
    elsif line =~ /public static final int MINOR = ([0-9]+);/
      n = $1
    elsif line =~ /public static final int POINT = ([0-9]+);/
      p = $1
    end
  end
  mnp = "#{m}#{n}#{p}"
end

#puts mnp

`git branch`.each_line do |line|
  #eweb_900_work_b27
  if line =~ /^\*/
    if line =~ /eweb_([0-9]+)_work/
      if !mnp
        mnp = $1
      elsif $1 != mnp
        puts "Branch name #{$1} doesn't match buildno #{mnp}"
      else #if $1 == mnp
        #puts "Branch name #{$}1 matches buildno #{mnp}"
      end
    end
  end
end

if mnp == ""
  mnp = '800'
end

# puts "mnp: #{mnp}"

backups = "/cygdrive/c/backups/"
if RUBY_PLATFORM =~ /darwin/
  backups = "#{ENV['HOME']}/backups/"
end

t = Time.now

date = sprintf( "%04d-%02d-%02d", t.year, t.mon, t.day )

tar = "#{backups}#{prefix}#{mnp}-git-#{date}.tar.gz"
cmd = "tar -czf #{tar} #{root}.git"
puts "cmd: #{cmd}"
system cmd
system "ls -l #{tar}"
