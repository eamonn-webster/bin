#
# File: reorg.rb
# Author: eweb
# Copyright eweb, 2018-2018
# Contents:
#
# Date:          Author:  Comments:
#  7th Apr 2018  eweb     #0007 rubocop
#
require 'FileUtils'

root = '/Users/eweb/accounts'
folder = 'java'
begin
  Dir.new("#{root}/#{folder}").each do |f|
    if File.directory?("#{root}/#{folder}/#{f}")
      Dir.chdir("#{root}/#{folder}/#{f}")
      Dir.new('.').each do |ff|
        if ff =~ /[a-z][a-z][a-z][0-9][0-9]\.(cbk|dry|bbb|slt)/
          #puts( "FileUtils.move(#{ff}, #{ff.capitalize})" )
          `git mv #{ff} #{ff}.tmp`
          `git mv #{ff}.tmp #{ff.capitalize}`
        end
      end
    end
  end
ensure
  Dir.chdir(root)
end
