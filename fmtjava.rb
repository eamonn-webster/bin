#!/usr/bin/env ruby

#
# File: fmtjava.rb
# Author: eweb
# Copyright eweb, 2018-2018
# Contents:
#
# Date:          Author:  Comments:
#  7th Apr 2018  eweb     #0007 rubocop
#
#<path-to-eclipse>\eclipse.exe -vm <path-to-vm>\java.exe
#                              -application org.eclipse.jdt.core.JavaCodeFormatter
#                              -verbose
#                              -config <path-to-config-file>\org.eclipse.jdt.core.prefs
#                              <path-to-your-source-files>\*.java

eclipse = '/dev2/eclipse/eclipse'
projdir = "#{ENV['HOME']}/projects/wacc/java/acc"
files = "#{projdir}/src/org/eweb/cpp/AbstractItemList.java"

# TODO generate configuration file
# by taking global settings from ~/eweb-format-java.xml and merging them with org.eclipse.jdt.core.prefs

config = "#{ENV['HOME']}/jdt.core.prefs"
File.open(config, 'w') do |output|
  File.open("#{projdir}/.settings/org.eclipse.jdt.core.prefs").each do |line|
    output.puts line
  end
  File.open("#{ENV['HOME']}/eweb-format-java.xml").each do |line|
    if line =~ /<setting id="(.+)" value="(.+)"\/>/
      output.puts "#{$1}=#{$2}\n"
    end
  end
end

cmd = "#{eclipse} -noSplash -application org.eclipse.jdt.core.JavaCodeFormatter -verbose -config #{config} #{files}"

puts cmd
