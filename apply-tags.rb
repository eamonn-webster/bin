#
# File: apply-tags.rb
# Author: eweb
# Copyright eweb, 2012-2012
# Contents:
#
# Date:          Author:  Comments:
# 25th Oct 2012  eweb     #0008 Create tags for commits that specify versions
#
gitlog = `git log --oneline`

gitlog.each_line do |line|
  if line =~ /([a-f0-9]{7}) #0001 ([2-9])\.([0-9])\.([0-9])\.([0-9]+)/
    puts line
    #puts [$1, $2, $3, $4, $5].to_s
    commit = $1
    major = $2
    minor = $3
    point = $4
    build = $5
    build = "%03d" % build.to_i
    mnp = "#{major}#{minor}#{point}"
    tag = "ACC_#{mnp}_BUILD_#{build}"
    puts "found #{commit} for #{tag}"
    `git tag #{tag} #{commit}`
  end
end

