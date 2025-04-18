#!/usr/bin/env ruby
# frozen_string_literal: true

#
# File: open_url.rb
# Author: eweb
# Copyright eweb, 2025-2025
# Contents:
#
# Date:          Author:  Comments:
# 18th Apr 2025  eweb     #0008 open in chrome profile
#

require 'json'

class OpenURL
  def main(argv)
    profile = profile_name(argv[1])
    cmd = %(open -n -a "Google Chrome" --args #{argv[0]})
    cmd = %(#{cmd} --profile-directory="#{profile}") if profile
    `#{cmd}`
  end

  def profile_name(name)
    return unless name && name[0]

    local_state_path = "#{Dir.home}/Library/Application Support/Google/Chrome/Local State"
    local_state = JSON.load_file(local_state_path)
    local_state['profile']['info_cache'].each do |k, v|
      return k if v['user_name'] == name
    end
    nil
  end

  def usage
    puts("#{__FILE__} url email")
  end

  def self.main(argv)
    new.main(argv)
  end

  def self.run(program_name)
    return unless program_name == __FILE__

    OpenURL.main(ARGV)
  end
end

OpenURL.run($PROGRAM_NAME)
