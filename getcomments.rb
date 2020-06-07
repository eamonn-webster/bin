#!/usr/bin/env ruby
#
# File: getcomments.rb
# Author: eweb
# Copyright eweb, 1995-2018
# Contents:
#
# Date:          Author:  Comments:
# 24th Feb 2010  eweb     #0008 Scrape comments from files
# 24th Jun 2014  eweb     #0008 Port to ruby
#  3rd Sep 2014  eweb     #0008 Hint if no comments
#  7th Apr 2018  eweb     #0007 rubocop
#

class Integer
  def ordinal
    if (11..13).cover?(abs % 100)
      'th'
    else
      case abs % 10
      when 1
        'st'
      when 2
        'nd'
      when 3
        'rd'
      else
        'th'
      end
    end
  end

  def ordinalize
    "#{self}#{ordinal}"
  end
end

@comments = []

opts = {}
@scc = nil
@verbose = true

def getopts(str, opts)
  valid_opts = {}
  prev = nil
  str.chars do |ch|
    if ch == ':'
      valid_opts[prev] = true
    else
      valid_opts[prev = ch] = nil
    end
  end
  keep = []
  prev = nil
  ARGV.each do |arg|
    if prev
      opts[prev] = arg.dup
      prev = nil
    elsif arg[0] == '-'
      cmd = arg[1]
      if valid_opts.key?(cmd)
        prev = valid_opts[cmd] ? cmd : nil
        opts[cmd] = true
      else
        return false
      end
    else
      keep << arg
    end
  end
  ARGV.clear
  ARGV.concat(keep)
  true
end

# Was anything other than the defined option entered on the command line?
if !getopts('s:l:v:d:t:', opts) || ARGV.any?
  print STDERR "Unknown arg #{ARGV[0]}\n" if ARGV.any?
  #Usage()
  exit
end

@cwd = Dir.getwd
drive = 'c:'
if @cwd =~ /^([a-z]:)/i
  drive = $1
end
if opts.key?('d')
  drive = opts['d']
end
@verbose = opts['v']
@scc = opts['s'].to_sym if opts['s']
@rev = opts['l']
@test = opts['t']

def find_git(where = '.')
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

def git_dir
  git = find_git
  if git
    Dir.chdir(git)
    true
  end
end

def determine_scc
  if @scc.nil?
    @scc = if @cwd =~ /^c:\/p4clients/i || @cwd =~ /^c:\\p4clients/i
             :p4
           elsif git_dir
             :git
           elsif Dir.exist?('\.svn') || Dir.exist?('.svn')
             :svn
           else
             :clearcase
           end
  end
  if @scc == :git || @rev == ''
    @rev = 'HEAD'
  end
end

def format_date(d, m, y)
  d = d.to_i
  th = d.ordinal
  if d < 10
    d = " #{d}"
  end

  "#{d}#{th} #{m} #{y}"
end

def onefile(file, since)
  #puts "onefile(#{file}, #{since})"
  puts file if @verbose
  # got the changes, open the file and see if they are within range.

  if @scc == :git
    diffcmd = "git diff #{since} -- #{file}"
  elsif @scc == :p4
    diffcmd = "p4 diff -du #{file}"
  elsif @scc == :clearcase
    diffcmd = "cleartool diff -diff -pred #{file}"
  elsif @scc == :svn
    diffcmd = "svn diff #{file}"
  end
  puts diffcmd if @verbose
  @old_comments = []
  l = 0
  `#{diffcmd} 2>&1`.lines.each do |line|
    line.chomp!
    l += 1
    # deal with the file.
    #print
    # TODO 1) the add indicator + for git and svn, > for clearcase
    # TODO 2) the single prefix null, #, -- depening on file type
    # TODO 3) the history item
    if line =~ /^(\+|-|> )(#|--)? +([0-9]+)(st|nd|rd|th)? +([A-Z][a-z]+) +([0-9]+) +([^ ]+) +(#[0-9?]+.*)/
      #print "file: #{line}\n" if @verbose
      #print file if @verbose
      puts "[#{line}]" if @verbose
      mark = $1
      # day = $3
      # month = $4
      # year = $6
      # user = $7
      comment = $8
      #puts comment
      if comment =~ /(#[^ ]+) *(.*)/
        bugid = $1
        text = $2
        text.strip!
        if mark == '-'
          puts "saving [#{bugid} #{text}]" if @verbose
          @old_comments << "#{bugid} #{text}"
        else
          puts 'looking for [bugid text] in (@old_comments)' if @verbose
          if @old_comments.none? { |c| c == "#{bugid} #{text}" }
            #print "#{bugid} [#{text}]\n"
            if @comments.none? { |c| c == comment }
              @comments << comment
            end
          end
        end
      end
    elsif line =~ /^ / && @old_comments
      #puts "#{l}: #{line}" if @verbose
      #puts "clearing oldComments" if @verbose
      @old_comments = []
    end
  end
end

def get_comments
  if @scc == :git
    since = @rev.to_s
    cmd = "git diff --name-only #{since}"
  elsif @scc == :p4
    cmd = 'p4 diff -sa'
  elsif @scc == :clearcase
    cmd = 'cleartool lsco -cview -avobs -short'
    #cmd = "dir /b *.pl"
  elsif @scc == :svn
    cmd = 'svn status -q'
    #cmd = "dir /b *.pl"
  end
  puts cmd if @verbose
  `#{cmd} 2>&1`.lines do |line|
    line.chomp!
    # deal with the file.

    if @scc == :svn
      if line =~ /^[AM].......(.+)/
        line = $1
      else
        next
      end
    end
    onefile(line, since)
  end
  @comments = @comments.sort
  @comments.reverse
end

determine_scc

output = drive.downcase
output.delete!(':')
output.gsub!(/[\/\\]/, '-')

os = `uname`.chomp.downcase

def unix?(os)
  %w[darwin linux].include?(os)
end

output = if unix?(os)
           'comments.dat'
         else
           ENV['TEMP'] + "\\#{output}-comments.dat"
         end

editor = if os == 'linux'
           'emacs'
         elsif os == 'darwin'
           'aquamacs'
         else
           'textpad'
         end

comments = get_comments
if comments.empty?
  puts "no comments try #{$PROGRAM_NAME} -l --cached"
  File.delete(output)
else
  puts "#{comments.size} comments"
  File.open(output, 'w') do |out|
    comments.each do |c|
      out.puts c
    end
  end
  print "#{editor} #{output}\n\n"
end
