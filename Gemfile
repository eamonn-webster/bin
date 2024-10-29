#
# File: Gemfile
# Author: eweb
# Copyright eweb, 2016-2023
# Contents:
#
# Date:          Author:  Comments:
# 28th Oct 2017  eweb     #0008 tidy up
# 11th Aug 2018  eweb     #0008 rake & cocoapods
# 26th Nov 2018  eweb     #0008 include metric_fu etc
# 21st Dec 2020  eweb     #0008 executable-hooks
# 21st Apr 2021  eweb     #0008 remove rubocop
# 17th Apr 2023  eweb     #0008 rubocop
#  6th Oct 2023  eweb     #3511 activesupport 7.1.0 breaks cocoapods
#
source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

gem 'bundler'
gem 'rubygems-bundler'
gem 'executable-hooks'
gem 'rake'
gem 'mailcatcher', require: false
gem 'irb'
gem 'nokogiri', require: false
gem 'rubocop', require: false
gem 'rubocop-performance', require: false
gem 'rubocop-rake', require: false
# bundle config taglib-ruby --with-tag-dir=`brew --prefix taglib`
gem 'taglib-ruby', '< 2.0.0', require: false
gem 'rest-client', require: false
gem 'pdf-reader', require: false
gem 'cocoapods', require: false

# gem 'metric_fu', github: 'eamonn-webster/metric_fu', require: false
# gem 'flog', github: 'eamonn-webster/flog', require: false
# gem 'reek', require: false
gem 'rubrowser', require: false

gem "pronto-rubocop", "~> 0.11.5"
