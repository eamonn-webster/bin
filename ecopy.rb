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
# 28th Mar 2015  eweb     #0008 ecopy.rb from bin
# 28th Mar 2015  eweb     #1723 Adapted for use in app
#  6th Apr 2015  eweb     #0007 tidy up
#  6th Apr 2015  eweb     #0007 break once copied or removed
#

# ruby replacement for ecopy.exe

# -s source folder
# -d destination folder
# -r recursive
# -n[-] only newer
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

  def diff_cmd(dst, src)
    "diff -u '#{dst}' '#{src}'"
  end

  def ediff_cmd(dst, src)
    "emacs --eval \"(ediff-files \\\"#{src}\\\" \\\"#{dst}\\\")\""
  end

  def view_file(file)
    cmd = "less '#{file}'"
    puts "cmd: #{cmd}"
    system cmd
  end

  def diff_files(destination, source)
    cmd = diff_cmd(destination, source)
    puts "cmd: #{cmd}"
    system cmd
    # puts ""
  end

  def ediff_files(destination, source)
    cmd = ediff_cmd(destination, source)
    puts "cmd: #{cmd}"
    system cmd
  end
end

class ECopy
  def initialize(io=nil)
    @io = io || AppIO.new
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

  def match_file_one(file, opt)
    #puts( "match_file_one(#{file},#{opt})" )
    if opt
      File.fnmatch(opt, file)
    end
  end

  def match_file(file)
    otherwise = true
    inc = true
    if options
      options.each do |opt|
        if opt == '-x'
          inc = false
        elsif opt =~ /^-/
        else
          if inc
            puts "opt = [#{opt}] setting otherwise to false"
            otherwise = false
          end
          if match_file_one(file, opt)
            puts "match_file( #{file}, #{opt} ) ==> #{inc}" if verbose
            return inc
          end
          inc = true
        end
      end
    end
    # no explicit match
    puts "match_file( #{file} ) ==> #{otherwise}" if verbose
    otherwise
  end

  def contents_of_folder(folder)
    contents = Dir.glob("#{folder}/*").collect { |x| x.sub("#{folder}/", "") }.sort
    contents.reject do |file|
      !match_file(file) && !File.directory?("#{folder}/#{file}")
    end
  end

  def create_dir(dir)
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

  def create_dir_if_needed(prompt, dest_dir, switches)
    if !switches['N'] && !File.directory?(dest_dir) && !File.file?(dest_dir)
      #puts "switches #{switches}"
      # if the directory doesn't exist
      print prompt
      dir_ans = create_dir(dest_dir)
      if dir_ans.upcase == dir_ans
        #puts "Setting switch #{dir_ans}"
        switches[dir_ans] = true
      end
      if dir_ans == 'q'
        dir_ans
      elsif dir_ans.downcase == 'n'
        dir_ans.downcase
      elsif dir_ans.downcase == 's'
        dir_ans.downcase
      end
    end
  end

  def process_file_ans(prompt, switches)
    if switches['Y']
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
      #puts "have added #{ans} to #{switches}"
      ans = ans.downcase
    end
    ans
  end

  def process_file_copy(source, destination)
    dest_dir = File.dirname(destination)
    if !File.directory?(dest_dir) && !File.file?(dest_dir)
      create_dir(dest_dir)
    end
    if File.directory?(dest_dir)
      copy_file(source, destination, true)
    end
  end

  def process_file_back(source, destination)
    if !File.file?(destination)
      puts "Can't copy back destination #{destination} doesn't exist"
    else
      copy_file(destination, source, true)
    end
  end

  def process_file_remove(source, destination, reverse)
    if reverse
      puts "FileUtils.remove_file(#{destination},true)"
      FileUtils.remove_file(destination, true)
    else
      puts "FileUtils.remove_file(#{source},true)"
      FileUtils.remove_file(source, true)
    end
  end

  def process_file_view(source, destination)
    if File.file?(destination)
      view_file(destination)
    elsif File.file?(source)
      view_file(source)
    end
  end

  def process_file(prompt, source, destination, switches, reverse=nil)
    if File.directory?(source)
      process_folder(source, destination, switches)
    elsif File.directory?(destination)
      process_folder(source, destination, switches)
    else
      while true
        dest_dir = File.dirname(destination)
        dir_ans = create_dir_if_needed(prompt, dest_dir, switches)
        return dir_ans if dir_ans

        ans = process_file_ans(prompt, switches)

        case ans
          when 'c', 'y'
            process_file_copy(source, destination)
            return
          when 'b'
            process_file_back(source, destination)
            return
          when 'r'
            process_file_remove(source, destination, reverse)
            return
          when 'd'
            diff_files(destination, source)
          when 'e'
            ediff_files(destination, source)
          when 'v'
            process_file_view(source, destination)
          when 'q'
            return ans
          else
            return
        end
      end
    end
  end

  def view_file(file)
    @io.view_file(file)
  end

  def diff_files(file1, file2)
    @io.diff_files(file1, file2)
  end

  def ediff_files(file1, file2)
    @io.ediff_files(file1, file2)
  end

  def compare_files(source, destination)
    puts "compare_files(#{source},#{destination})" if verbose
    only_newer = !options.find { |x| x == "-n-" }
    if only_newer
      if File.mtime(source) <= File.mtime(destination)
        puts "compare_files(File.mtime(#{source}) <= File.mtime(#{destination})" if verbose
        return true
      end
      puts "src: #{File.mtime(source)} #{source}\ndst: #{File.mtime(destination)} #{destination}" if verbose
    end

    if FileUtils.compare_file(source, destination)
      puts "FileUtils.compare_file(#{source},#{destination}) => true" if verbose
      true
    else
      puts "FileUtils.compare_file(#{source},#{destination}) => false" if verbose
      diff_files(destination, source)
      false
    end
  end

  def process_folder_mismatch(adds, deletes, compares, source, destination)
    adds.each do |add|
      deletes.each do |del|
        if del.downcase == add.downcase
          prompt = "Case mismatches a) #{del} and b) #{add}?"
          ans = get_response prompt
          if ans == 'b'
            rename_file "#{destination}/#{del}", "#{destination}/#{add}"
            adds.delete(add)
            deletes.delete(del)
            compares.push(add)
          elsif ans == 'a'
            rename_file "#{source}/#{add}", "#{source}/#{del}"
            adds.delete(add)
            deletes.delete(del)
            compares.push(del)
          end
        end
      end
    end
  end

  def process_folder_adds(source, destination, adds, local_switches)
    puts "Files in #{source} but not in #{destination}" unless adds.empty?
    adds.each do |file|
      source_file = "#{source}/#{file}"
      destination_file = "#{destination}/#{file}"
      if file =~ /\(.*conflicted copy.*\)/
        stem = file.sub(/ \(.*conflicted copy.*\)/, '')
        ans = process_file("add file #{source_file} #{source}/#{stem}? (c/r/d/e/v)", source_file, "#{source}/#{stem}", local_switches)
      else
        ans = process_file("add file #{source_file} #{destination_file}? (c/r/v)", source_file, destination_file, local_switches)
      end
      #puts "local_switches #{local_switches}"
      return ans if ans == 'q'
      return ans if ans == 's'
      return ans if ans == 'n' # no to create directory not no to a file
    end
    nil
  end

  def process_folder_deletes(source, destination, deletes, local_switches)
    puts "Files not in #{source} but in #{destination}" unless deletes.empty?
    deletes.each do |file|
      source_file = "#{source}/#{file}"
      destination_file = "#{destination}/#{file}"
      ans = process_file("remove file #{destination_file}? (r/b/v)", source_file, destination_file, local_switches, true)
      return ans if ans == 'q'
    end
    nil
  end

  def process_folder_compares(source, destination, compares, local_switches)
    compares.each do |file|
      source_file = "#{source}/#{file}"
      destination_file = "#{destination}/#{file}"
      if File.file?(source_file) && File.file?(destination_file)
        if !compare_files(source_file, destination_file)
          ans = process_file("copy file #{source_file}? (c/r/b/d/e)", source_file, destination_file, local_switches)
          return ans if ans == 'q'
        end
      elsif File.directory?(source_file) && File.directory?(destination_file)
        ans = process_folder(source_file, destination_file, local_switches)
        return ans if ans == 'q'
      elsif File.directory?(source_file) && File.file?(destination_file)
        if verbose
          puts "#{source_file} shadowed by file #{destination_file}"
        end
      elsif File.file?(source_file) && File.directory?(destination_file)
        if verbose
          puts "#{source_file} is shadow for directory #{destination_file}"
        end
      end
    end
  end

  def process_folder(source, destination, switches)
    puts source
    source = source[0..-2] if source.end_with?('/')
    destination = destination[0..-2] if destination.end_with?('/')
    local_switches = switches.clone

    source_files = contents_of_folder(source)
    destination_files = contents_of_folder(destination)

    adds = source_files - destination_files
    deletes = destination_files - source_files
    compares = destination_files - (destination_files - source_files)

    process_folder_mismatch(adds, deletes, compares, source, destination)

    ans = process_folder_adds(source, destination, adds, local_switches)
    return ans if ans == 'q'
    return if ans == 's'
    return if ans == 'n' # no to create directory not no to a file

    ans = process_folder_deletes(source, destination, deletes, local_switches)
    return ans if ans == 'q'
    ans = process_folder_compares(source, destination, compares, local_switches)
    return ans if ans == 'q'
    nil
  end

  def verbose
    options.find { |x| x == "-v" }
  end

  attr_accessor :options

  def get_source(argv)
    p = options.find_index('-s')
    if p
      source_root = options[p+1]
      options[p..p+1] = []
      source_root
    end
  end
  def get_destination(argv)
    p = options.find_index('-d')
    if p
      destination_root = options[p+1]
      options[p..p+1] = []
      destination_root
    end
  end

  def run(argv)
    self.options = argv
    source_root = get_source(argv)
    destination_root = get_destination(argv)

    unless File.directory?(source_root)
      puts "source_root #{source_root} not found"
      return
    end

    process_folder(source_root, destination_root, {})
  end

end

if $0 == __FILE__
  require 'FileUtils'
  ECopy.new.run(ARGV)
end
