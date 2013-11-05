#!/usr/bin/env ruby
#
# File: tag-releases.rb
# Author: eweb
# Copyright eweb, 2013-2013
# Contents:
#
# Date:          Author:  Comments:
#  5th Nov 2013  eweb     #0008 Tag releases
#

apps = [ARGV[0]]

apps = %w{qs-alpha qs-bleedin qs-analytics} if apps.empty?

apps.each do |app|
  releases = %x{heroku releases --app #{app}}
  releases.each_line do |release|
    #puts release
    fields = release.split(/\s+/)
    if fields[1] == 'Deploy'
      ver = fields[0]
      commit = fields[2]
      tag = "#{app}-#{ver}".upcase
      x = %x{git tag #{tag} #{commit} 2>&1}
      if x =~ /fatal: tag '#{tag}' already exists/
      elsif x =~ /fatal:/
        puts x
      else
        puts "created tag #{tag} on commit #{commit}"
        x = %x{git push origin #{tag} 2>&1}
        if x =~ /fatal:/
          puts x
        end
      end
    end
  end
end
