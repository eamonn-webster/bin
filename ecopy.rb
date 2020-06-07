#!/usr/bin/env ruby
#
# File: ecopy.rb
# Author: eweb
# Copyright eweb, 2016-2019
# Contents:
#
# Date:          Author:  Comments:
# 25th Sep 2016  eweb     #0008 require wacc version
#  7th Apr 2018  eweb     #0007 rubocop
# 25th Apr 2018  eweb     #0008 require other files
# 11th Aug 2018  eweb     #0008 update path
# 27th Jan 2019  eweb     #0008 need blank
# 15th Aug 2019  eweb     #2923 File matcher
#

$LOAD_PATH.unshift '~/projects/acc/ruby/lib/acc'

require 'FileUtils'
require 'blank'
require 'app_io'
require 'ecopy_io'
require 'ecopy'
require 'ecopy_callbacks'
require 'ecopy_process_file'
require 'ecopy_process_folder'
require 'option_file_matcher'

if ARGV.empty?
  puts 'usage ecopy.rb -s source -d dest other-options'
else
  ECopy.run(ARGV)
end
