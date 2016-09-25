#!/usr/bin/env ruby
#
# File: ecopy.rb
# Author: eweb
# Copyright eweb, 2016-2016
# Contents:
#
# Date:          Author:  Comments:
# 25th Sep 2016  eweb     #0008 require wacc version
#

$:.unshift '~/projects/wacc/ruby/lib/acc'

require 'FileUtils'
require 'ecopy'

if ARGV.empty?
  puts "usage ecopy.rb -s source -d dest other-options"
else
  ECopy.new.run(ARGV)
end
