#!/usr/bin/env ruby
#
# File: codiffs.rb
# Author:
# Copyright eweb, 2012-2015
# Contents:
#
# Date:          Author:  Comments:
# 19th Jul 2012  eweb     #0008 Initial port to ruby
#  5th Aug 2012  eweb     #0008 Write codiffs.txt
#  5th Aug 2012  eweb     #0008 Include git add commands
#  5th Aug 2012  eweb     #0008 git add only for untracked files
#  6th Aug 2012  eweb     #0008 Make cos.sh executable
# 10th Sep 2012  eweb     #0008 deleted, modified, renamed and new file
# 10th Sep 2012  eweb     #0008 pushd and popd
# 10th Sep 2012  eweb     #0008 make cos.sh executable
# 24th Oct 2012  eweb     #0008 Report number of files changed
#  7th Nov 2013  eweb     #0008 Use addcomment.rb
# 24th Jun 2014  eweb     #0008 git output changes, no diffs file
# 20th Aug 2014  eweb     #0008 Cleaner output
#  3rd Sep 2014  eweb     #0008 Delete file if no changes
# 20th Sep 2014  eweb     #0008 Don't delete cos.sh
# 25th Mar 2015  eweb     #0008 Always push and pop dir
#

def find_git( where = "." )
  where = File.expand_path where
  #puts "Trying #{where}\n"
  if File.directory?("#{where}/.git")
    where
  elsif where == '/'
  else
    up = File.expand_path "#{where}/.."
    #puts "up #{up}\n"
    find_git up if up != where
  end
end

verbose = false

project_root = find_git

exit unless project_root

addcomment = 'addcomment.rb'

need_to_change_directory = Dir.pwd != project_root

Dir.chdir project_root if need_to_change_directory

script_file = project_root + '/cos.sh'
#diffs_file = project_root + '/codiffs.txt'

#puts script_file

changed_files = []

  IO.popen("git status") do |f|
    stage = nil
    f.each do |line|
      #puts line
      if line =~ /On branch (.*)/
        branch = $1
      elsif line =~ /Your branch is up-to-date with '.+'/
      elsif line =~ /Your branch is ahead of '.+'/
      elsif line =~ /nothing to commit, working directory clean/
      elsif line =~ /Changes to be committed:/
        stage = :staged
      elsif line =~ /\tdeleted: +(.*)/
        #
      elsif line =~ /\tmodified: +(.*)/ ||
            line =~ /\trenamed: +(?:.*) -> (.*)/ ||
            line =~ /\tnew file: +(.*)/
        file = $1
        puts "Staged #{file}\n" if stage == :staged && verbose
        puts "Unstaged #{file}\n" if stage == :unstaged && verbose
        changed_files << stage
        changed_files << file
      elsif line =~ /Untracked files:/
        stage = :untracked
      elsif line =~ /Changes not staged for commit:/
        stage = :unstaged
      elsif line =~ /\t(.*)/
        file = $1
        puts "Untracked #{file}" if verbose
        changed_files << stage
        changed_files << file
      elsif line =~ / \(use/
      elsif line == "\n"
      elsif line =~ /^[^#]/
        puts "Unhandled #{line}"
      else
        puts "Unhandled #{line}"
      end
    end
  end

def get_comments file #, diffs
  comments = []
  # git diff compares working tree with index what could be staged
  # git diff --cached compares index with HEAD what has been staged
  IO.popen("git diff HEAD -- #{file}") do |f|
    f.each do |line|
      if line =~ /\+# ([0-9]{1,2}th|st|nd|rd) ([A-Z][a-z]{2}) ([0-9]{4})  (.+)     (.+)/
        puts "Comment: #{$1} #{$2} #{$3} #{$4} #{$5}\n"
        comments << $5
      else
        #diffs.puts line
      end
    end
  end
  comments
rescue => e
  puts "Error scanning file #{file} for comments #{e}"
  []
end

if changed_files.length
  files_changed = 0
  File.open( script_file, "w" ) do |script|
    script.puts "pushd #{project_root}" # if need_to_change_directory
    stage =
    changed_files.each do |f|
      if f.class == Symbol
        script.puts "### #{f}" if stage != f
        stage = f
      else
        files_changed = files_changed + 1
        comments = get_comments f #, diffs
        if stage == :untracked
          script.puts "#git add #{f}"
        end
        if comments.length > 0
          comments.each do |c|
            script.puts "##{addcomment} -c \"#{c}\" #{f}"
          end
        else
          script.puts "#{addcomment} -c \"\" #{f}"
        end
      end
    end
    script.puts "popd" # if need_to_change_directory
  end
  puts "#{files_changed} files changed"

  mode = File.stat( script_file ).mode & 0777
  # executable by owner
  File.chmod( mode | 0100, script_file )
  if files_changed > 0
    puts "aquamacs #{script_file}"
  end
end

