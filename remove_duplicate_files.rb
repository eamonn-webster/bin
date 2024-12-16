# frozen_string_literal: true
require 'digest'
require 'fileutils'

# Function to calculate the hash of a file
def file_hash(file_path)
  Digest::MD5.file(file_path).hexdigest
end

# Function to remove duplicate images
def remove_duplicate_images(folder_path)
  puts "Scanning folder: #{folder_path}"

  files = Dir.glob(File.join(folder_path, '*'))
  image_files = files.select { |file| File.file?(file) && file =~ /\.(jpg|jpeg|png|gif|bmp|tiff)$/i }

  puts "Found #{image_files.size} image files."

  hashes = {}
  duplicates = []

  image_files.each do |file|
    hash = file_hash(file)
    if hashes[hash]
      duplicates << file
      puts "Duplicate found: #{file} (matches #{hashes[hash]})"
    else
      hashes[hash] = file
    end
  end

  if duplicates.empty?
    puts "No duplicates found."
  else
    puts "Removing duplicates..."
    duplicates.each do |duplicate|
      File.delete(duplicate)
      puts "Deleted: #{duplicate}"
    end
  end

  puts "Duplicate removal complete."
end

# Main script
def main(argv)
  if argv.length < 1
    puts "Usage: ruby remove_duplicates.rb <folder_path>"
    return
  end

  folder_path = argv[0]

  unless Dir.exist?(folder_path)
    puts "Error: Folder '#{folder_path}' does not exist."
    return
  end

  remove_duplicate_images(folder_path)
end

if $PROGRAM_NAME == __FILE__
  main(ARGV)
end

