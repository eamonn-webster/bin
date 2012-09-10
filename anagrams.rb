#
# File: anagrams.rb
# Author: eweb
# Copyright eweb, 2012-2012
# Contents:
#
# Date:          Author:  Comments:
# 10th Sep 2012  eweb     #0008 Anagrams
#
require 'spellchecker'
require 'tempfile'

def anagrams (k,w)
  fixed = k.chars.to_a
  g = k.chars.count { |c| c == '?' }
  letters = w.chars.to_a
  if g != letters.size
    puts "#{g} ? but #{leters.size} letters"
  else
    letters.permutation do |p|
      word = k.chars.collect do |c|
        c == '?' ? p.pop : c
      end
      word = word.join
      chk = Spellchecker.check( word )
      puts word if chk[0][:correct]
    end
    nil
  end
end
