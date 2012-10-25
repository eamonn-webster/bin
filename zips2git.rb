#!/usr/bin/env ruby
#
# File: zips2git.rb
# Author: eweb
# Copyright eweb, 2012-2012
# Contents:
#
# Date:          Author:  Comments:
# 25th Oct 2012  eweb     #0008 Import historical data from zip files
#

def getkey
  system("stty raw -echo") #=> Raw mode, no echo
  char = STDIN.getc
  system("stty -raw echo") #=> Reset terminal mode
  exit if char.ord == 3
  raise Exception.new '^C' if char.ord == 3
  char
end

def unzip(zipdir, workdir)
  mons = %w{Huh Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec}
  dates = {}
  zips = %x{find #{zipdir} -name '*.zip'}
  zips.each_line do |z|
    z.sub! /[\r\n]+$/, ''
    bz = File.basename(z)
    if bz =~ /[pl][0-9]{2}.*\.zip/ # lisp
    elsif bz =~ /(h[0-9]{2}|acd|aic)\.zip/ # undated
    elsif bz =~ /aic([0-9]{4})(...)([0-9]{2})\.zip/
      # icons
    elsif bz =~ /acd([0-9]{4})(...)([0-9]{2})\.zip/
      # need these
      date = "#{$1}#{'%02d' % mons.index($2)}#{$3}"
      dates[date] = (dates[date] || []) << z
    elsif bz =~ /h([0-9]{2})([0-9]{4})(...)([0-9]{2})\.zip/
      # these are the ones we need to process
      date = "#{$2}#{'%02d' % mons.index($3)}#{$4}"
      dates[date] = (dates[date] || []) << z
    else # unhandled
      puts z
    end
  end
  dates.sort.each do |date,files|
    #puts date
    #getkey
    commit_time = nil
    files.each do |file|
      commit_time = File.mtime(file) if !commit_time || File.mtime(file) > commit_time
      b = File.basename(file)
      dir = "#{workdir}/Desktop"
      if b =~ /^h0([0-9])/
        dir = "#{workdir}/Desktop/#{$1.to_i + 2000}"
      elsif b =~ /^h([8-9][0-9])/
        dir = "#{workdir}/Desktop/#{$1.to_i + 1900}"
      end
      cmd = "rm #{dir}/* 2>&1"
      #puts "#{cmd}"
      %x{#{cmd}}
      cmd = "unzip #{file} -d #{dir}"
      puts "#{cmd}"
      %x{#{cmd}}
    end
    fix_names( File.expand_path(workdir) )
    %x{git add --all .}
    ENV['GIT_AUTHOR_DATE'] = commit_time.to_s
    ENV['GIT_COMMITTER_DATE'] = commit_time.to_s
    %x{git commit -m #{date}}
  end
  nil
end

def fix_names(dir)
  Dir.glob("#{dir}/**/*") do |path|
    if File.file? path
      new_path = path
      b = File.basename(path)
      if b == b.upcase
        new_path = new_path.sub(/#{b}$/, b.downcase)
        b = File.basename(new_path)
      end
      if b =~ /[a-zA-Z]{3}[0-9]{2}\..../
        new_path = new_path.sub(/#{b}$/, b.capitalize)
      else
        e = File.extname(new_path)
        new_path = new_path.sub(/#{e}$/, e.downcase)
      end
      File.rename( path, new_path ) if path != new_path
    end
  end
end

zipsdir = File.expand_path( '~/iomega0/eamonn/accounts' )
workdir = File.expand_path( '~/workdir' )

%x{rm -rf #{workdir}}
Dir.mkdir(workdir)
Dir.mkdir("#{workdir}/Desktop")
Dir.chdir(workdir)
%x{git init}

unzip zipsdir, workdir
