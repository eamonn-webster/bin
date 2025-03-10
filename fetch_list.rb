#!/usr/bin/env ruby

# frozen_string_literal: true

#
# File: fetch_list.rb
# Author: eweb
# Copyright eweb, 2025-2025
# Contents:
#
# Date:          Author:  Comments:
# 10th Mar 2025  eweb     #0008 1000 albums
#

# Usage:
# fetch_list.rb http://1001albumsyoumusthearbeforeyoudie.wikidot.com/frank-sinatra-in-the-wee-small-hours ~/Downloads/albums.csv

require 'nokogiri'
require 'open-uri'
require 'csv'

class FetchList
  def self.main(argv)
    new.run(argv)
  end

  def run(argv)
    count = 0
    albums = []
    init = URI.parse(argv[0])
    get = [init.path]
    got = []
    link_classes = %w[.skip1 .skip3]
    until get.empty?
      x = get.pop
      got.push(x)
      init.path = x
      begin
        doc = Nokogiri::HTML(URI.open(init))
        title = doc.css('title').inner_text
        title = title.gsub('’', "'")
        artist, album = title.split(' - ')
        count += 1
        puts %(#{count}: "#{artist}" "#{album}")
        status = ''
        if Dir.exist?("#{Dir.home}/Music/iTunes/iTunes Media/Music/#{artist}/#{album}")
          status = 'GOT'
        end
        albums << [status, artist, album, init.to_s]
        link_classes.each do |clss|
          link = doc.css(clss)
          link = link.at('a/@href').to_s
          if !got.include?(link) && !get.include?(link)
            get << link
          end
        end
      rescue StandardError => e
        puts "#{e.class} #{e.message}"
        sleep(3)
        get.push(got.pop)
      end
    end
    str = CSV.generate(+"\uFEFF") do |csv|
      csv << %w[Status Artist Album URL]
      albums.each do |a|
        csv << a
      end
    end
    File.write(argv[1], str)
  end

  def self.run(program_name)
    return unless program_name == __FILE__

    main(ARGV)
  end
end

FetchList.run($PROGRAM_NAME)
