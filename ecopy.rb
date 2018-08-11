#!/usr/bin/env ruby
#
# File: ecopy.rb
# Author: eweb
# Copyright eweb, 2016-2018
# Contents:
#
# Date:          Author:  Comments:
# 25th Sep 2016  eweb     #0008 require wacc version
#  7th Apr 2018  eweb     #0007 rubocop
# 25th Apr 2018  eweb     #0008 require other files
# 11th Aug 2018  eweb     #0008 update path
#

$LOAD_PATH.unshift '~/projects/acc/ruby/lib/acc'

require 'FileUtils'
require 'app_io'
require 'ecopy_io'
require 'ecopy'
require 'ecopy_callbacks'
require 'ecopy_process_file'
require 'ecopy_process_folder'

if ARGV.empty?
  puts "usage ecopy.rb -s source -d dest other-options"
else
  ECopy.new.run(ARGV)
end
