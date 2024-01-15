#!/usr/bin/env ruby

#
# File: anagrams.rb
# Author: eweb
# Copyright eweb, 2012-2024
# Contents:
#
# Date:          Author:  Comments:
# 10th Sep 2012  eweb     #0008 Anagrams
# 24th Oct 2012  eweb     #0008 Multiple words
#  7th Apr 2018  eweb     #0007 rubocop
# 13th Jan 2024  eweb     #0008 command line args
#
require 'spellchecker'
require 'tempfile'

def anagrams(w, k = '')
  # fixed = k.chars.to_a
  w = w.downcase
  k = k.downcase
  g = k.chars.count { |c| c == '.' }
  if g.zero?
    g = w.size
    k = '.' * g
  end
  letters = w.chars.to_a
  if g != letters.size
    k.chars.each do |ch|
      next if ch == '.'

      w = w.sub(ch, '')
    end
    letters = w.chars.to_a
  end
  if g != letters.size
    puts "#{g} ? but #{letters.size} letters"
  else
    words = []
    letters.permutation do |p|
      word = k.chars.collect do |c|
        c == '.' ? p.pop : c
      end
      word = word.join
      if words.index(word)
        next
      end
      chk = Spellchecker.check(word)
      if chk.all? { |x| x[:correct] }
        puts word
        words << word
      end
    end
    nil
  end
end

if __FILE__ == $PROGRAM_NAME
  anagrams(*ARGV)
end
