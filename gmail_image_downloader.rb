#!/usr/bin/env ruby

require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'base64'
require 'mime'
require 'webrick'
require 'nokogiri'
require 'open-uri'
# Configure Gmail API
REDIRECT_URI = 'http://127.0.0.1:4567'.freeze
APPLICATION_NAME = 'Gmail API Ruby'.freeze
CREDENTIALS_PATH = 'credentials.json'.freeze
TOKEN_PATH = 'token.yaml'.freeze
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
    if src.include?('.ru')
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
      file_name = "user-files-#{rand(1000000)}.png"
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

# # Main script
# if ARGV.length < 1
#   puts "Usage: ruby extract_images.rb <html_file_or_url>"
#   exit
# end
#
# input = ARGV[0]
# base_url = nil
# html_content = nil
#
# # Check if input is a local file or URL
# if input =~ URI::DEFAULT_PARSER.make_regexp
#   puts "Fetching HTML from URL: #{input}"
#   html_content = URI.open(input).read
#   base_url = input # Use URL as the base for relative paths
# else
#   puts "Reading HTML from file: #{input}"
#   html_content = File.read(input)
# end

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
      puts "Processing message ID: #{msg.id}"
      download_attachments(gmail, msg.id, output_dir)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  main(ARGV)
end
