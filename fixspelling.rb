#! /usr/bin/env ruby

Dir.glob("**/*").each do |file|
  if File.file? file
    puts file
    changed = false
    File.open( "#{file}.tmp", "w" ) do |output|
      File.open( file, "r" ) do |input|
        input.each do |line|
          new_line = line.gsub( /"Mellon"/, '"Melon"' )
          changed = true if new_line != line
          output.print new_line
        end
      end
    end
    if changed
      File.delete( "#{file}.old" ) if File.exists? "#{file}.old"
      File.rename( file, "#{file}.old" )
      File.rename( "#{file}.tmp", file )
    else
      File.delete( "#{file}.tmp" )
    end
  end
end
