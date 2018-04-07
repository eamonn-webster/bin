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
#

$LOAD_PATH.unshift '~/projects/wacc/ruby/lib/acc'

require 'FileUtils'
require 'ecopy'

if ARGV.empty?
  puts "usage ecopy.rb -s source -d dest other-options"
else
  ECopy.new.run(ARGV)
end
