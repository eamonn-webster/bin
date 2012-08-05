#!/usr/bin/env ruby
#
# File: ecopy.rb
# Author: eweb
# Copyright eweb, 1989-2011
# Contents:
#
# Date:          Author:  Comments:
# 25th Aug 2011  eweb     #0008 Rewrite ecopy in ruby
# 25th Aug 2011  eweb     #0008 Does it remove execute permissions
# 25th Aug 2011  eweb     #0008 Does it remove execute permissions - yes it does
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
# make writeable / checkout

testing = true
sourceRoot = ""
destinationRoot = ""

puts( "ecopy.rb " + ARGV.join( ' ' ) )
#puts "ARGV: " + ARGV.join( ', ')
p = ARGV.find_index( "-s" )
if p
  sourceRoot = ARGV[p+1]
  ARGV[p..p+1] = []
end
#puts "ARGV: " + ARGV.join( ', ')
p = ARGV.find_index( "-d" )
if p
  destinationRoot = ARGV[p+1]
  ARGV[p..p+1] = []
end

#puts "ARGV: " + ARGV.join( ', ')

puts "sourceRoot: #{sourceRoot}"
puts "destinationRoot: #{destinationRoot}"

unless File.directory?(sourceRoot)
  puts "sourceRoot #{sourceRoot} not found\n"
  exit
end

def match_file_one( file, opt )
  #puts( "match_file_one(#{file},#{opt})" )
  if ( opt ) 
    File.fnmatch( opt, file )
  end
end

def match_file( file, options )
  otherwise = true
  inc = true
  if ( options )
    options.each do | opt |
      if opt == '-x'
        inc = false
      elsif ( opt =~ /^-/ )
      else
        if ( inc )
          puts "opt = [#{opt}] setting otherwise to false\n"
          otherwise = false
        end
        if ( match_file_one( file, opt ) )
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

def contents_of_folder( folder, options )
  contents = Dir.glob("#{folder}/*").collect { |x| x.sub( "#{folder}/", "" ) }.sort
  contents.reject do | file |
    !match_file( file, options ) and !File.directory?( "#{folder}/#{file}")
  end
end

def get_key
  #begin
  #`stty raw -echo`
  #return STDIN.getc()
  return STDIN.gets()[0..0]
  #ensure
  #`stty -raw echo`
  #end
end

def get_response( prompt )
  print prompt
  ch = get_key()
  #print "#{ch}\n"
  ch
end

def create_dir( dir, options )
  if File.directory?(dir)
  else
    prompt = "Create directory #{dir}? (y/n/s)"
    while true
      ans = get_response( prompt )
      if ( ans.downcase == 'y' )
        FileUtils.makedirs( dir )
        return ans
      elsif ( ans.downcase == 'n' )
        return ans
      elsif ( ans.downcase == 's' )
        dirdir = File.dirname(dir)
        FileUtils.makedirs( dirdir )
        FileUtils.touch( dir )
        # shadow...
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

def copy_file( source, destination, verbose )
  # permissions
  # do we retain permissions or do we copy them?
  # if the destination files existed should the new file have the same permissions as the old file
  # or the same as the source file? If copying from a fat device then the source might not have
  # the proper rights.
  source_mode = File.stat( source ).mode
  if ( File.file?( destination ) )
    destination_mode = File.stat( destination ).mode
    mode = destination_mode
  else
    mode = source_mode
  end
  puts "copy_file(#{source},#{destination})"

  FileUtils.copy_file(source,destination,verbose)
  File.chmod( mode, destination )
end

def rename_file( source, destination )
  puts "rename_file(#{source},#{destination})"

  File.rename( source, destination )
end

def process_file( prompt, source, destination, options, switches )
  if File.directory?(source)
    return process_folder( source, destination, options, switches )
  elsif File.directory?(destination)
    return process_folder( source, destination, options, switches )
  else
    while true
      destDir = File.dirname(destination)
      ans = false
      if ( !switches['N'] and !File.directory?( destDir ) and !File.file?( destDir ) )
        #puts "switches #{switches}\n"
        # if the directory doesn't exist
        print prompt
        dirans = create_dir( destDir, options )
        if ( dirans.upcase == dirans )
          #print "Setting switch #{dirans}\n"
          switches[dirans] = true
        end
        if (dirans == 'q' )
          return dirans
        elsif (dirans.downcase == 'n' )
          return dirans.downcase
        elsif (dirans.downcase == 's' )
          return dirans.downcase
        end
      end
      #puts "switches: #{switches}\n"
      if ( ans )
      elsif ( switches['Y'] )
        ans = 'y'
      elsif ( switches['C'] )
        ans = 'c'
      elsif ( switches['N'] )
        ans = 'n'
      elsif ( switches['B'] )
        ans = 'b'
      elsif ( switches['R'] )
        ans = 'r'
      else
        ans = get_response( prompt )
      end
      if ( ans == ans.upcase )
        switches[ans] = true
        #puts "have added #{ans} to #{switches}\n"
        ans = ans.downcase
      end
      if ( ans == 'c' or ans == 'y' )
        destDir = File.dirname(destination)
        if ( !File.directory?( destDir ) and !File.file?( destDir ) )
          create_dir( destDir, options )
        end
        if ( File.directory?( destDir ) )
          copy_file(source,destination,true)
        end
        break
      elsif ( ans == 'b' )
        if !File.file?( destination )
          puts "Can't copy back destination #{destination} doesn't exist"
        else
          copy_file(destination,source,true)
        end
        break
      elsif (ans == 'r' )
        puts "FileUtils.remove_file(#{source},true)"
        FileUtils.remove_file(source,true)
        break
      elsif (ans == 'd' )
        cmd = diff_cmd( destination, source )
        puts "d: #{cmd}\n"
        system cmd
      elsif (ans == 'e' )
        cmd = ediff_cmd( destination, source )
        puts "e: #{cmd}\n"
        system cmd
      elsif (ans == 'v' )
        if ( File.file?( destination ) )
          cmd = "less '#{destination}'"
          puts "cmd: #{cmd}\n"
          system cmd
        elsif ( File.file?( source ) )
          cmd = "less '#{source}'"
          puts "cmd: #{cmd}\n"
          system cmd
        end
      elsif (ans == 'q' )
        return ans
      else
        break
      end
    end
  end
end

#Dir.glob("*").sort {|a,b| File.ctime(a) <=> File.ctime(b) }

def diff_cmd( dst, src )
  return "diff -u '#{dst}' '#{src}'"
end

def ediff_cmd( dst, src )
  return "emacs --eval \"(ediff-files \\\"#{src}\\\" \\\"#{dst}\\\")\""
end

def compare_files( source, destination, options )
  puts "compare_files(#{source},#{destination})\n" if options.find { |x| x == "-v" }
  only_newer = true unless options.find { |x| x == "-n-" }
  if only_newer
    if File.mtime(source) <= File.mtime(destination) 
      puts "compare_files(File.mtime(#{source}) <= File.mtime(#{destination})\n" if options.find { |x| x == "-v" }
      return true
    end
    puts "src: #{File.mtime(source)} #{source}\ndst: #{File.mtime(destination)} #{destination}\n" if options.find { |x| x == "-v" }
  end
  
  if FileUtils.compare_file( source, destination )
    puts "FileUtils.compare_file(#{source},#{destination}) => true\n" if options.find { |x| x == "-v" }
    true    
  else
    puts "FileUtils.compare_file(#{source},#{destination}) => false\n" if options.find { |x| x == "-v" }
    cmd = diff_cmd( destination, source )
    puts "cmd: #{cmd}\n"
    system cmd
    puts "\n"
    false
  end
end

def process_folder( source, destination, options, switches )
  puts source
  source = source[0..-2] if source.end_with?('/')
  destination = destination[0..-2] if destination.end_with?('/')
  local_switches = switches.clone
  sourceFiles = contents_of_folder( source, options )
  destinationFiles = contents_of_folder( destination, options )
  adds = sourceFiles - destinationFiles
  deletes = destinationFiles - sourceFiles
  compares = destinationFiles - (destinationFiles - sourceFiles)
  #puts "Files in source #{sourceFiles.join( ', ' )}\n"
  #puts "Files in destination #{destinationFiles.join( ', ' )}\n"
  #puts "Files to be added #{adds.join( ', ' )}\n"
  #puts "Files to be removed #{deletes.join( ', ' )}\n"
  #puts "Files to be compared #{compares.join( ', ' )}\n"

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

  #puts "Files to be added #{adds.join( ', ' )}\n"
  #puts "Files to be removed #{deletes.join( ', ' )}\n"
  #puts "Files to be compared #{compares.join( ', ' )}\n"

  puts "Files in #{source} but not in #{destination}" unless adds.empty?
  adds.each do | file |
    ans = process_file( "add file #{source}/#{file} #{destination}/#{file}? (c/r/v)", "#{source}/#{file}","#{destination}/#{file}", options, local_switches )
    #puts "local_switches #{local_switches}\n"
    return ans if ans == 'q'
    return if ans == 's'
    return if ans == 'n' # no to create directory not no to a file
  end
  puts "Files not in #{source} but in #{destination}" unless deletes.empty?
  deletes.each do | file |
    ans = process_file( "remove file #{destination}/#{file}? (c/r/b/v)", "#{source}/#{file}","#{destination}/#{file}", options, local_switches )
    return ans if ans == 'q'
  end
  compares.each do | file |
    if ( File.file?( "#{source}/#{file}" ) and File.file?( "#{destination}/#{file}" ) )
      if ( !compare_files( "#{source}/#{file}", "#{destination}/#{file}", options ) )
        ans = process_file( "copy file #{source}/#{file}? (c/r/b/d/e)", "#{source}/#{file}","#{destination}/#{file}", options, local_switches )
        return ans if ans == 'q'
      end
    elsif ( File.directory?( "#{source}/#{file}" ) and File.directory?( "#{destination}/#{file}" ) )
      ans = process_folder( "#{source}/#{file}","#{destination}/#{file}", options, local_switches )
      return ans if ans == 'q'
    elsif ( File.directory?( "#{source}/#{file}" ) and File.file?( "#{destination}/#{file}" ) )
      if ( switches['v'] ) 
        puts "#{source}/#{file} shadowed by file #{destination}/#{file}\n"
      end
    elsif ( File.file?( "#{source}/#{file}" ) and File.directory?( "#{destination}/#{file}" ) )
      if ( switches['v'] ) 
        puts "#{source}/#{file} is shadow for directory #{destination}/#{file}\n"
      end
    end
  end
end

puts "options: " + ARGV.join( ' ' ) + "\n"
switches = {}
process_folder( sourceRoot, destinationRoot, ARGV, switches )
