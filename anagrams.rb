#
# File: anagrams.rb
# Author: eweb
# Copyright eweb, 2012-2018
# Contents:
#
# Date:          Author:  Comments:
# 10th Sep 2012  eweb     #0008 Anagrams
# 24th Oct 2012  eweb     #0008 Multiple words
#  7th Apr 2018  eweb     #0007 rubocop
#
require 'spellchecker'
require 'tempfile'

def anagrams(k, w)
  # fixed = k.chars.to_a
  g = k.chars.count { |c| c == '?' }
  letters = w.chars.to_a
  if g != letters.size
    puts "#{g} ? but #{letters.size} letters"
  else
    letters.permutation do |p|
      word = k.chars.collect do |c|
        c == '?' ? p.pop : c
      end
      word = word.join
      chk = Spellchecker.check(word)
      puts word if chk.all? { |x| x[:correct] }
    end
    nil
  end
end
