#!/usr/bin/env ruby

# frozen_string_literal: true

#
# File: gmail_image_downloader.rb
# Author: eamonn.webster@gmail.com
# Copyright eweb, 2024-2025
# Contents:
#
# Date:          Author:  Comments:
# 12th Jan 2025  eweb     #0008 include duplicate deletion and rejects
# 16th Jan 2025  eweb     #0008 alway process files
#

require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'base64'
require 'mime'
require 'webrick'
require 'nokogiri'
require 'open-uri'
require 'digest'

# Configure Gmail API
REDIRECT_URI = 'http://127.0.0.1:4567'.freeze
APPLICATION_NAME = 'Gmail API Ruby'.freeze
CREDENTIALS_PATH = "#{__dir__}/credentials.json".freeze
TOKEN_PATH = "#{__dir__}/token.yaml".freeze
SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

# Start a local server to handle OAuth callback
def start_local_server
  server = WEBrick::HTTPServer.new(Port: 4567, Logger: WEBrick::Log.new(File::NULL), AccessLog: [])
  auth_code = nil

  server.mount_proc('/') do |req, res|
    auth_code = req.query['code']
    res.body = 'Authentication successful! You can close this tab.'
    server.shutdown
  end

  Thread.new { server.start }
  sleep 0.5 while auth_code.nil? # Wait for the auth_code to be set
  auth_code
end

# Authorize the user
def authorize
  client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)

  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: REDIRECT_URI)
    puts "Open the following URL in your browser to authorize the application:\n#{url}"
    auth_code = start_local_server
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: auth_code, base_url: REDIRECT_URI
    )
  end

  credentials
end

# Fetch messages from Gmail
def fetch_messages(gmail, folder)
  query = "in:#{folder}"
  user_id = 'me'
  result = gmail.list_user_messages(user_id, q: query)
  result.messages || []
end

# Extract embedded images
def download_attachments(gmail, message_id, output_dir)
  user_id = 'me'
  message = gmail.get_user_message(user_id, message_id)

  # Create output directory if it doesn't exist
  FileUtils.mkdir_p(output_dir)

  if message.payload.parts.nil?
    html_content = message.payload.body.data
    extract_images(html_content, output_dir)
  else
    foo(message, gmail, message_id, output_dir)
  end
end

def foo(message, gmail, message_id, output_dir)
  user_id = 'me'
  message.payload.parts.each do |part|
    if part.mime_type.start_with?('text/html')
      html_content = part.body.data
      extract_images(html_content, output_dir)
    elsif part.mime_type.start_with?('image/')
      begin
        attachment_id = part.body.attachment_id
        attachment = gmail.get_user_message_attachment(user_id, message_id, attachment_id)
        filename = part.filename || 'unknown_image'
        filepath = File.join(output_dir, filename)

        begin
          data = Base64.urlsafe_decode64(attachment.data)
        rescue ArgumentError => e
          data = attachment.data
        end

        File.binwrite(filepath, data)
        puts "Downloaded: #{filepath}"
      rescue StandardError => e
        puts "Error: #{e}"
      end
    end
  end
end

# Function to extract image URLs from HTML
def extract_images_from_html(html_content, base_url = nil)
  doc = Nokogiri::HTML(html_content)
  image_urls = []

  # Extract all <img> tags and their 'src' attributes
  doc.css('img').each do |img_tag|
    src = img_tag['src']
    next unless src # Skip if 'src' is nil
    if src.include?('.ru') || src.include?('open.gif')
      puts "skipping #{src}"
      next
    end

    # Convert relative URLs to absolute if base_url is provided
    image_url = base_url ? URI.join(base_url, src).to_s : src
    image_urls << image_url
  end

  image_urls
end

# Function to download images to a specified directory
def download_images(image_urls, output_dir)
  FileUtils.mkdir_p(output_dir) # Create directory if it doesn't exist

  extension_map = {'image/jpeg' => '.jpg',
                   'image/png' => '.png',
                   'image/gif' => '.gif'}
  image_urls.each do |url|
    puts "Downloading: #{url}"
    file_name = File.basename(URI.parse(url).path)
    if file_name == 'user-files'
      file_name = "user-files-#{Time.now.to_f}.png"
    end
    file_path = File.join(output_dir, file_name)

    # Open and save the file
    URI.open(url) do |image|
      File.binwrite(file_path, image.read)
    end
    puts "Saved: #{file_path}"
    ext = File.extname(file_path)
    type = `file -b --mime-type "#{file_path}"`.strip
    new_suffix = extension_map[type]
    new_file_path = "#{file_path.delete_suffix(ext)}#{new_suffix}"
    if new_suffix && new_file_path != file_path
      `mv "#{file_path}" "#{new_file_path}"`
      puts "Saved: #{new_file_path}"
    end
  rescue StandardError => e
    puts "Failed to download #{url}: #{e.message}"
  end
end

# Extract and download images
def extract_images(html_content, output_dir)
  puts 'Extracting images...'
  image_urls = extract_images_from_html(html_content, nil)

  if image_urls.empty?
    puts 'No images found in the HTML.'
  else
    puts "Found #{image_urls.length} images. Downloading..."
    download_images(image_urls, output_dir)
  end
end

# Function to calculate the hash of a file
def file_hash(file_path)
  Digest::MD5.file(file_path).hexdigest
end

# Function to remove duplicate images
def remove_duplicate_images(folder_path, hashes)
  puts "Scanning folder: #{folder_path}"
  image_files = images_in_folder(folder_path)
  puts "Found #{image_files.size} image files."

  duplicates = find_duplicates(image_files, hashes)

  remove_files(duplicates)
end

def find_duplicates(files, hashes)
  duplicates = []
  files.each do |file|
    hash = file_hash(file)
    if hashes.key?(hash) && hashes[hash] != file
      duplicates << file
      puts "Duplicate found: #{file} (matches #{hashes[hash]})"
    elsif hashes[hash] != file
      hashes[hash] = file
    end
  end
  duplicates
end

def remove_rejects(folder_path)
  files = images_in_folder(folder_path)
  remove_files(files, quiet: true)
end
def images_in_folder(folder_path)
  files = Dir.glob(File.join(folder_path, '*'))
  files.select { |file| File.file?(file) && file =~ /\.(jpg|jpeg|png|gif|bmp|tiff)$/i }
end
def add_hashes_for_files(folder_path, hashes)
  files = Dir.glob(File.join(folder_path, '*'))
  image_files = files.select { |file| File.file?(file) && file =~ /\.(jpg|jpeg|png|gif|bmp|tiff)$/i }

  image_files.each do |file|
    hash = file_hash(file)
    unless hashes.key?(hash)
      hashes[hash] = file
    end
  end
  hashes
end
def remove_files(files, quiet: false)
  if files.empty?
    # puts "No files to remove." unless quiet
  else
    puts "Removing files..."  unless quiet
    files.each do |file|
      File.delete(file)
      puts "Deleted: #{file}" unless quiet
    end
  end
end

def load_hashes(path)
  if File.exist?(path)
    puts "loading #{path}"
    JSON.load_file(path)
  else
    {}
  end
end
def save_hashes(hashes, path)
  File.write(path, hashes.to_json)
end

def main(argv)
  # Initialize the Gmail service
  gmail = Google::Apis::GmailV1::GmailService.new
  gmail.client_options.application_name = APPLICATION_NAME
  gmail.authorization = authorize
  folder = argv[0] || 'inbox'
  output_dir = argv[1] || "#{Dir.home}/Downloads/images"

  # Main script
  puts 'Fetching messages with attachments...'
  messages = fetch_messages(gmail, folder)

  if messages.empty?
    puts 'No messages found with attachments.'
  else
    messages.each do |msg|
      next unless msg

      puts "Processing message ID: #{msg.id}"
      download_attachments(gmail, msg.id, output_dir)
    end
  end

  hashes = load_hashes("#{output_dir}/rejects/rejects.json")
  # puts "have #{hashes.size} rejects"
  add_hashes_for_files("#{output_dir}/rejects", hashes)
  # puts "adding rejected files now have #{hashes.size} rejects"
  save_hashes(hashes,"#{output_dir}/rejects/rejects.json")
  remove_duplicate_images(output_dir, hashes)
  remove_rejects("#{output_dir}/rejects")
end

if __FILE__ == $PROGRAM_NAME
  main(ARGV)
end
