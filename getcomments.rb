#!/usr/bin/env ruby
#
# File: getcomments.rb
# Author: eweb
# Copyright eweb, 1995-2014
# Contents:
#
# Date:          Author:  Comments:
# 24th Feb 2010  eweb     #0008 Scrape comments from files
# 24th Jun 2014  eweb     #0008 Port to ruby
#

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
      if valid_opts.has_key?(cmd)
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
if !getopts("s:l:v:d:t:", opts) or ARGV.size > 1
    print STDERR "Unknown arg #{ARGV[0]}\n" if ARGV.size > 0
    #Usage()
    exit
end

@cwd = Dir.getwd
drive = 'c:'
if @cwd =~ /^([a-z]:)/i
  drive = $1
end
if opts.has_key?('d')
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

def determinescc
  if @scc == nil
    if @cwd =~ /^c:\/p4clients/i or @cwd =~ /^c:\\p4clients/i
      @scc = :p4
    elsif git_dir
      @scc = :git
    elsif Dir.exist? '\.svn' or Dir.exist? '.svn'
      @scc = :svn
    else
      @scc = :clearcase
    end
  end
  if @scc == :git and @rev == ''
    @rev = 'HEAD'
  end
end

def formatDate(d, m ,y)
  th = 'th'
  d = d.to_i
  if d == 1 || d == 21 || d == 31
    th = 'st'
  elsif d == 2 || d == 22
    th = 'nd'
  elsif d == 3 || d == 23
    th = 'rd'
  end
  if d < 10
    d = " #{d}"
  end

  "#{d}#{th} #{m} #{y}"
end

def onefile(file, since, out)
  #puts "onefile(#{file}, #{since}, #{out})"
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
  @oldComments = []
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
        day = $3
        month = $4
        year = $6
        user = $7
        comment = $8
        #puts comment
        if comment =~ /(#[^ ]+) *(.*)/
          bugid = $1
          text = $2
          text.strip!
          if mark == '-'
            puts "saving [#{bugid} #{text}]" if @verbose
            @oldComments << "#{bugid} #{text}"
          else
            puts "looking for [bugid text] in (@oldComments)" if @verbose
            if @oldComments.none?{ |c| c == "#{bugid} #{text}"}
              #print "#{bugid} [#{text}]\n"
              #out.print "rem addcomment.pl -c \"#{comment}\" \"#{file}\"\n"
              if @comments.none?{ |c| c == comment }
                @comments << comment
              end
            end
          end
        end
      else
        if line =~ /^ / && @oldComments
          #puts "#{l}: #{line}" if @verbose
          #puts "clearing oldComments" if @verbose
          @oldComments = []
        end
      end
    end
  end

def comments(out)
  if @scc == :git
    since = "#{@rev}"
    cmd = "git diff --name-only #{since}"
  elsif @scc == :p4
    cmd = "p4 diff -sa"
  elsif @scc == :clearcase
    cmd = "cleartool lsco -cview -avobs -short"
    #cmd = "dir /b *.pl"
  elsif @scc == :svn
    cmd = "svn status -q"
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
      onefile(line, since, out)
  end
  @comments = @comments.sort
  @comments = @comments.reverse
  @comments.each do |c|
    #out.puts "REM #{c}"
    out.puts c
  end
end

determinescc

editor = 'textpad'
output = drive.downcase
output.gsub!(':', '')
output.gsub!(/[\/\\]/, '-')

os = %x{uname}.chomp.downcase

output = ENV['TEMP'] + "\\#{output}-comments.dat" unless os == 'darwin' or os == 'linux'
output = 'comments.dat' if os == 'darwin' or os == 'linux'
editor = 'emacs' if os == 'linux'
editor = 'aquamacs' if os == 'darwin'

print "#{editor} #{output}\n\n"

File.open(output, 'w') do |h|
  comments(h)
end
