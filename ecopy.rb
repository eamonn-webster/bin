#!/usr/bin/env ruby
#
# File: ecopy.rb
# Author: eweb
# Copyright eweb, 1989-2016
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
# 27th Apr 2015  eweb     #0007 process_folder_compares
# 30th Apr 2015  eweb     #0007 process_folder_compares_one
# 17th May 2015  eweb     #2232 Were no longer detecting differences
# 26th May 2015  eweb     #0007 avoid [0..0]
#  3rd Aug 2015  eweb     #0007 process_file and get_folder
#  6th Sep 2015  eweb     #0007 refactor
# 28th Sep 2015  eweb     #0007 create_dir, compare_files
# 10th Jan 2016  eweb     #0007 rubocop
#  6th Mar 2016  eweb     #2213 callbacks
#  6th Mar 2016  eweb     #0007 coverage
# 26th Mar 2016  eweb     #0007 rubocop
# 27th Mar 2016  eweb     #0007 strip_trailing_slash
# 23rd Apr 2016  eweb     #2401 Logging of actions
# 23rd Apr 2016  eweb     #2401 logging
# 14th May 2016  eweb     #0007 compare_files
# 23rd Jun 2016  eweb     #2455 Must include options in the prompt
# 21st Aug 2016  eweb     #0008 copied from wacc
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
    Kernel.puts(msg)
  end

  def print(msg)
    Kernel.print(msg)
  end

  def get_key
    STDIN.gets[0]
  end

  def get_response(prompt)
    print prompt
    get_key
  end

  def info(msg)
    puts(msg)
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

module ECopyIO
  def puts(msg)
    @io.puts(msg)
  end

  def trace(msg)
    @io.puts(msg) if verbose
  end

  def print(msg)
    @io.print(msg)
  end

  def get_response(prompt)
    @io.get_response(prompt)
  end

  def info(msg)
    @io.info(msg)
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
end

class ECopy
  include ECopyIO

  def initialize(io = nil)
    @io = io || AppIO.new
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
            trace "match_file(#{file}, #{opt}) ==> #{inc}"
            return inc
          end
          inc = true
        end
      end
    end
    # no explicit match
    trace "match_file(#{file}) ==> #{otherwise}"
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
      ans = get_response(prompt)
      case ans.downcase
      when 'y'
        FileUtils.makedirs(dir)
      when 's'
        dir_dir = File.dirname(dir)
        FileUtils.makedirs(dir_dir)
        FileUtils.touch(dir)
      end
      ans
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
    if File.file?(destination)
      mode = File.stat(destination).mode
    else
      mode = File.stat(source).mode
    end
    info "copying file '#{source}' to '#{destination}'"

    FileUtils.copy_file(source, destination, verbose)
    File.chmod(mode, destination)
  end

  def rename_file(source, destination)
    info "renaming file '#{source}' to '#{destination}'"
    File.rename(source, destination)
  end

  def create_dir_if_needed(prompt, dest_dir, switches)
    if !switches['N'] && !File.directory?(dest_dir) && !File.file?(dest_dir)
      print prompt
      dir_ans = create_dir(dest_dir)
      if dir_ans =~ /[A-Z]/
        switches[dir_ans] = true
      end
      'qns'[dir_ans.downcase]
    end
  end

  def compare_files_times(source, destination)
    only_newer = !options.find { |x| x == "-n-" }
    if only_newer
      source_mtime = File.mtime(source)
      dest_mtime = File.mtime(destination)
      if source_mtime <= dest_mtime
        trace "compare_files(File.mtime(#{source}) <= File.mtime(#{destination})"
        return true
      end
      trace "src: #{source_mtime} #{source}\ndst: #{dest_mtime} #{destination}"
    end
  end

  def compare_files(source, destination)
    trace "compare_files(#{source},#{destination})"
    if compare_files_times(source, destination)
      return true
    end

    same = FileUtils.compare_file(source, destination)
    trace "FileUtils.compare_file(#{source},#{destination}) => #{same}"
    unless same
      diff_files(destination, source)
    end
    same
  end

  def verbose
    options.find { |x| x == "-v" }
  end

  attr_accessor :options

  def get_folder(flag)
    p = options.find_index(flag)
    if p
      folder = options[p + 1]
      options[p..p + 1] = []
      folder
    end
  end

  def get_source
    get_folder('-s')
  end

  def get_destination
    get_folder('-d')
  end

  def run(argv)
    self.options = argv
    source_root = get_source
    destination_root = get_destination
    unless File.directory?(source_root)
      puts "source_root #{source_root} not found"
      return
    end
    process_folder(source_root, destination_root, {})
  end
end

module ProcessFile
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
    if ans =~ /[A-Z]/
      switches[ans] = true
      ans = ans.downcase
    end
    ans
  end

  def process_file_copy(source, destination)
    dest_dir = File.dirname(destination)
    raise "dest_dir is neither file nor directory" if !File.directory?(dest_dir) && !File.file?(dest_dir)
    if !File.directory?(dest_dir) && !File.file?(dest_dir)
      # create_dir(dest_dir)
    end
    if File.directory?(dest_dir)
      copy_file(source, destination, true)
      file_copied(destination)
    end
  end

  def process_file_back(source, destination)
    raise "destination is not a file" if !File.file?(destination)
    if !File.file?(destination)
      # puts "Can't copy back destination #{destination} doesn't exist"
    else
      copy_file(destination, source, true)
      file_backed(source)
    end
  end

  def remove_file(file)
    info "removing file '#{file}'"
    FileUtils.remove_file(file, true)
  end

  def process_file_remove(source, destination, reverse)
    if reverse
      remove_file(destination)
    else
      remove_file(source)
    end
  end

  def process_file_view(source, destination)
    if File.file?(destination)
      view_file(destination)
    elsif File.file?(source)
      view_file(source)
    end
  end

  def process_file_file(prompt, source, destination, switches, reverse)
    ans = process_file_ans(prompt, switches)
    process_file_file_action(ans, source, destination, reverse)
  end

  def process_file_file_action(ans, source, destination, reverse)
    case ans
    when 'c', 'y'
      process_file_copy(source, destination)
      throw :return
    when 'b'
      process_file_back(source, destination)
      throw :return
    when 'r'
      process_file_remove(source, destination, reverse)
      throw :return
    when 'd'
      diff_files(destination, source)
    when 'e'
      ediff_files(destination, source)
    when 'v'
      process_file_view(source, destination)
    when 'q'
      throw :return, ans
    else
      throw :return
    end
  end

  def process_file(prompt, source, destination, switches, reverse = nil)
    raise "source #{source} is a directory" if File.directory?(source)
    # process_folder(source, destination, switches)
    raise "destination #{destination} is a directory" if File.directory?(destination)
    #  process_folder(source, destination, switches)
    # else
    catch :return do
      loop do
        dest_dir = File.dirname(destination)
        dir_ans = create_dir_if_needed(prompt, dest_dir, switches)
        return dir_ans if dir_ans
        process_file_file(prompt, source, destination, switches, reverse)
      end
    end
    # end
  end

  ECopy.send(:include, ProcessFile)
end

module ProcessFolder
  def process_file_mismatch(source, destination, add, del)
    ans = get_response "Case mismatches a) #{del} and b) #{add} (a/b)?"
    if ans == 'b'
      rename_file "#{destination}/#{del}", "#{destination}/#{add}"
      add
    elsif ans == 'a'
      rename_file "#{source}/#{add}", "#{source}/#{del}"
      del
    end
  end

  def process_folder_mismatch(source, destination, adds, deletes, compares)
    adds.each do |add|
      deletes.each do |del|
        if del.casecmp(add) == 0
          comp = process_file_mismatch(source, destination, add, del)
          if comp
            adds.delete(add)
            deletes.delete(del)
            compares.push(comp)
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

  def file_or_directory(path)
    if File.directory?(path)
      :directory
    elsif File.file?(path)
      :file
    end
  end

  def process_folder_compares_one(source_file, destination_file, local_switches)
    source_type = file_or_directory(source_file)
    destination_type = file_or_directory(destination_file)
    case [source_type, destination_type]
    when [:file, :file]
      if !compare_files(source_file, destination_file)
        process_file("copy file #{source_file}? (c/r/b/d/e)", source_file, destination_file, local_switches)
      end
    when [:directory, :directory]
      process_folder(source_file, destination_file, local_switches)
    when [:directory, :file]
      trace "#{source_file} shadowed by file #{destination_file}"
    when [:file, :directory]
      trace "#{source_file} is shadow for directory #{destination_file}"
    end
  end

  def process_folder_compares(source, destination, compares, local_switches)
    compares.each do |file|
      source_file = "#{source}/#{file}"
      destination_file = "#{destination}/#{file}"
      if process_folder_compares_one(source_file, destination_file, local_switches) == 'q'
        return 'q'
      end
    end
    nil
  end

  def strip_trailing_slash(dir)
    dir.end_with?('/') ? dir[0..-2] : dir
  end

  def process_folder(source, destination, switches)
    puts source
    source = strip_trailing_slash(source)
    destination = strip_trailing_slash(destination)
    local_switches = switches.clone

    source_files = contents_of_folder(source)
    destination_files = contents_of_folder(destination)

    adds = source_files - destination_files
    deletes = destination_files - source_files
    compares = destination_files - (destination_files - source_files)

    process_folder_mismatch(source, destination, adds, deletes, compares)

    process_folder_aux(source, destination, adds, deletes, compares, local_switches)
  end

  def process_folder_aux(source, destination, adds, deletes, compares, local_switches)
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

  ECopy.send(:include, ProcessFolder)
end

module EcopyCallbacks
  def file_copied(file)
    @on_file_copy.call(file) if @on_file_copy
  end

  def file_backed(file)
    @on_file_back.call(file) if @on_file_back
  end

  def on_file_copy(&block)
    @on_file_copy = block
  end

  def on_file_back(&block)
    @on_file_back = block
  end

  ECopy.send(:include, EcopyCallbacks)
end

if $PROGRAM_NAME == __FILE__
  require 'FileUtils'
  ECopy.new.run(ARGV)
end
