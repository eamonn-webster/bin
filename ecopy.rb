#!/usr/bin/env ruby
#
# File: ecopy.rb
# Author: eweb
# Copyright eweb, 1989-2015
# Contents:
#
# Date:          Author:  Comments:
# 25th Aug 2011  eweb     #0008 Rewrite ecopy in ruby
# 25th Aug 2011  eweb     #0008 Does it remove execute permissions
# 25th Aug 2011  eweb     #0008 Does it remove execute permissions - yes it does
# 20th Sep 2014  eweb     #0008 conflicted copies
# 14th Oct 2014  eweb     #0008 Regexp for conflicted copies
# 25th Mar 2015  eweb     #0007 Reformat
# 25th Mar 2015  eweb     #0007 Classify
# 25th Mar 2015  eweb     #0007 Avoid infinite recursion
#
require 'FileUtils'

# ruby replacement for ecopy.exe

# -s source folder
# -d destination folder
# -r recursive
# -n[-] only newer
# -w windiff
# -Y pattern
# -N pattern

# process options
# walk a tree
# get files in a directory
# compare files by attributes
# compare files by content
# prompt user
# make backups
# shadowing
# make writable / checkout
class AppIO
  def puts(msg)
    Kernel::puts(msg)
  end
  def print(msg)
    Kernel::print(msg)
  end
  def get_key
    STDIN.gets[0..0]
  end
  def get_response(prompt)
    print prompt
    get_key
  end
  def system(cmd)
    Kernel::system cmd
  end
end

class ECopy
  def initialize
    @io = AppIO.new
  end

  def puts(msg)
    @io.puts(msg)
  end

  def print(msg)
    @io.print(msg)
  end

  def get_response(prompt)
    @io.get_response(prompt)
  end

  def system(cmd)
    @io.system(cmd)
  end

  def match_file_one(file, opt)
    #puts( "match_file_one(#{file},#{opt})" )
    if opt
      File.fnmatch(opt, file)
    end
  end

  def match_file(file, options)
    otherwise = true
    inc = true
    if options
      options.each do |opt|
        if opt == '-x'
          inc = false
        elsif opt =~ /^-/
        else
          if inc
            puts "opt = [#{opt}] setting otherwise to false\n"
            otherwise = false
          end
          if match_file_one(file, opt)
            puts "match_file( #{file}, #{opt} ) ==> #{inc}\n" if options.find { |x| x == "-v" }
            return inc
          end
          inc = true
        end
      end
    end
    # no explicit match
    puts "match_file( #{file} ) ==> #{otherwise}\n" if options.find { |x| x == "-v" }
    otherwise
  end

  def contents_of_folder(folder, options)
    contents = Dir.glob("#{folder}/*").collect { |x| x.sub("#{folder}/", "") }.sort
    contents.reject do |file|
      !match_file(file, options) && !File.directory?("#{folder}/#{file}")
    end
  end

  def create_dir(dir, options)
    if File.directory?(dir)
    else
      prompt = "Create directory #{dir}? (y/n/s)"
      while true
        ans = get_response(prompt)
        if ans.downcase == 'y'
          FileUtils.makedirs(dir)
          return ans
        elsif ans.downcase == 'n'
          return ans
        elsif ans.downcase == 's'
          dir_dir = File.dirname(dir)
          FileUtils.makedirs(dir_dir)
          FileUtils.touch(dir)
          return ans
        else
          return ans
        end
      end
    end
  end

# uppercase means apply to all
# q for quit this folder
# Q to terminate app
# need set of flags. yes_to_all, no_to_all etc...
# handle how these flags are applied
#  to this folder only
#  to this folder and all sub folders
#  from now on...

  def copy_file(source, destination, verbose)
    # permissions
    # do we retain permissions or do we copy them?
    # if the destination files existed should the new file have the same permissions as the old file
    # or the same as the source file? If copying from a fat device then the source might not have
    # the proper rights.
    source_mode = File.stat(source).mode
    if File.file?(destination)
      mode = File.stat(destination).mode
    else
      mode = source_mode
    end
    puts "copy_file(#{source},#{destination})"

    FileUtils.copy_file(source, destination, verbose)
    File.chmod(mode, destination)
  end

  def rename_file(source, destination)
    puts "rename_file(#{source},#{destination})"
    File.rename(source, destination)
  end

  def process_file(prompt, source, destination, options, switches, reverse=nil)
    if File.directory?(source)
      process_folder(source, destination, options, switches)
    elsif File.directory?(destination)
      process_folder(source, destination, options, switches)
    else
      while true
        dest_dir = File.dirname(destination)
        ans = false
        if !switches['N'] && !File.directory?(dest_dir) && !File.file?(dest_dir)
          #puts "switches #{switches}\n"
          # if the directory doesn't exist
          print prompt
          dir_ans = create_dir(dest_dir, options)
          if dir_ans.upcase == dir_ans
            #print "Setting switch #{dir_ans}\n"
            switches[dir_ans] = true
          end
          if dir_ans == 'q'
            return dir_ans
          elsif dir_ans.downcase == 'n'
            return dir_ans.downcase
          elsif dir_ans.downcase == 's'
            return dir_ans.downcase
          end
        end
        if ans
        elsif switches['Y']
          ans = 'y'
        elsif switches['C']
          ans = 'c'
        elsif switches['N']
          ans = 'n'
        elsif switches['B']
          ans = 'b'
        elsif switches['R']
          ans = 'r'
        else
          ans = get_response(prompt)
        end
        if ans == ans.upcase
          switches[ans] = true
          #puts "have added #{ans} to #{switches}\n"
          ans = ans.downcase
        end
        if ans == 'c' || ans == 'y'
          dest_dir = File.dirname(destination)
          if !File.directory?(dest_dir) && !File.file?(dest_dir)
            create_dir(dest_dir, options)
          end
          if File.directory?(dest_dir)
            copy_file(source, destination, true)
          end
          break
        elsif ans == 'b'
          if !File.file?(destination)
            puts "Can't copy back destination #{destination} doesn't exist"
          else
            copy_file(destination, source, true)
          end
          break
        elsif ans == 'r'
          if reverse
            puts "FileUtils.remove_file(#{destination},true)"
            FileUtils.remove_file(destination, true)
          else
            puts "FileUtils.remove_file(#{source},true)"
            FileUtils.remove_file(source, true)
          end
          break
        elsif ans == 'd'
          cmd = diff_cmd(destination, source)
          puts "d: #{cmd}\n"
          system cmd
        elsif ans == 'e'
          cmd = ediff_cmd(destination, source)
          puts "e: #{cmd}\n"
          system cmd
        elsif ans == 'v'
          if File.file?(destination)
            cmd = "less '#{destination}'"
            puts "cmd: #{cmd}\n"
            system cmd
          elsif File.file?(source)
            cmd = "less '#{source}'"
            puts "cmd: #{cmd}\n"
            system cmd
          end
        elsif ans == 'q'
          return ans
        else
          break
        end
      end
    end
  end

  def diff_cmd(dst, src)
    "diff -u '#{dst}' '#{src}'"
  end

  def ediff_cmd(dst, src)
    "emacs --eval \"(ediff-files \\\"#{src}\\\" \\\"#{dst}\\\")\""
  end

  def compare_files(source, destination, options)
    puts "compare_files(#{source},#{destination})\n" if options.find { |x| x == "-v" }
    only_newer = !options.find { |x| x == "-n-" }
    if only_newer
      if File.mtime(source) <= File.mtime(destination)
        puts "compare_files(File.mtime(#{source}) <= File.mtime(#{destination})\n" if options.find { |x| x == "-v" }
        return true
      end
      puts "src: #{File.mtime(source)} #{source}\ndst: #{File.mtime(destination)} #{destination}\n" if options.find { |x| x == "-v" }
    end

    if FileUtils.compare_file(source, destination)
      puts "FileUtils.compare_file(#{source},#{destination}) => true\n" if options.find { |x| x == "-v" }
      true
    else
      puts "FileUtils.compare_file(#{source},#{destination}) => false\n" if options.find { |x| x == "-v" }
      cmd = diff_cmd(destination, source)
      puts "cmd: #{cmd}\n"
      system cmd
      puts "\n"
      false
    end
  end

  def process_folder(source, destination, options, switches)
    puts source
    source = source[0..-2] if source.end_with?('/')
    destination = destination[0..-2] if destination.end_with?('/')
    local_switches = switches.clone
    source_files = contents_of_folder(source, options)
    destination_files = contents_of_folder(destination, options)
    adds = source_files - destination_files
    deletes = destination_files - source_files
    compares = destination_files - (destination_files - source_files)

    adds.each do |add|
      deletes.each do |del|
        if del.downcase == add.downcase
          prompt = "Case mismatches a) #{del} and b) #{add}?"
          ans = get_response prompt
          if ans == 'b'
            rename_file "#{destination}/#{del}", "#{destination}/#{add}"
            adds = adds - [add]
            deletes = deletes - [del]
            compares = compares + [add]
          elsif ans == 'a'
            rename_file "#{source}/#{add}", "#{source}/#{del}"
            adds = adds - [add]
            deletes = deletes - [del]
            compares = compares + [del]
          end
        end
      end
    end

    puts "Files in #{source} but not in #{destination}" unless adds.empty?
    adds.each do |file|
      if file =~ /\(.*conflicted copy.*\)/
        stem = file.sub(/ \(.*conflicted copy.*\)/, '')
        ans = process_file("add file #{source}/#{file} #{source}/#{stem}? (c/r/d/e/v)", "#{source}/#{file}", "#{source}/#{stem}", options, local_switches)
      else
        ans = process_file("add file #{source}/#{file} #{destination}/#{file}? (c/r/v)", "#{source}/#{file}", "#{destination}/#{file}", options, local_switches)
      end
      #puts "local_switches #{local_switches}\n"
      return ans if ans == 'q'
      return if ans == 's'
      return if ans == 'n' # no to create directory not no to a file
    end
    puts "Files not in #{source} but in #{destination}" unless deletes.empty?
    deletes.each do |file|
      ans = process_file("remove file #{destination}/#{file}? (r/b/v)", "#{source}/#{file}", "#{destination}/#{file}", options, local_switches, true)
      return ans if ans == 'q'
    end
    compares.each do |file|
      if File.file?("#{source}/#{file}") && File.file?("#{destination}/#{file}")
        if !compare_files("#{source}/#{file}", "#{destination}/#{file}", options)
          ans = process_file("copy file #{source}/#{file}? (c/r/b/d/e)", "#{source}/#{file}", "#{destination}/#{file}", options, local_switches)
          return ans if ans == 'q'
        end
      elsif File.directory?("#{source}/#{file}") && File.directory?("#{destination}/#{file}")
        ans = process_folder("#{source}/#{file}", "#{destination}/#{file}", options, local_switches)
        return ans if ans == 'q'
      elsif File.directory?("#{source}/#{file}") && File.file?("#{destination}/#{file}")
        if switches['v']
          puts "#{source}/#{file} shadowed by file #{destination}/#{file}\n"
        end
      elsif File.file?("#{source}/#{file}") && File.directory?("#{destination}/#{file}")
        if switches['v']
          puts "#{source}/#{file} is shadow for directory #{destination}/#{file}\n"
        end
      end
    end
  end

  def run(argv)
    source_root = ""
    destination_root = ""

    puts("ecopy.rb " + argv.join(' '))
    p = argv.find_index("-s")
    if p
      source_root = argv[p+1]
      argv[p..p+1] = []
    end
    p = argv.find_index("-d")
    if p
      destination_root = argv[p+1]
      argv[p..p+1] = []
    end

    puts "source_root: #{source_root}"
    puts "destination_root: #{destination_root}"

    unless File.directory?(source_root)
      puts "source_root #{source_root} not found\n"
      return
    end

    puts "options: " + argv.join(' ') + "\n"
    switches = {}
    process_folder(source_root, destination_root, argv, switches)
  end

end

ECopy.new.run(ARGV)
