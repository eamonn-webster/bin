#!/usr/bin/env ruby
#
# File: addcomment.rb
# Author: eweb
# Copyright eweb, 2003-2026
# Contents: Perl script to add comments to source files
#
# Date:          Author:  Comments:
# 27th Jan 2006  eweb     More args, Add banner and strip proto banner.
# 22nd Mar 2006  eweb     Check the file type.
# 17th May 2006  eweb     Other companies.
# 19th Jun 2006  eweb     Options.
# 19th Jun 2006  eweb     sql files, call to updateConfig.
#  3rd Jan 2007  eweb     -k Package for calls to updateConfig.
# 26th Apr 2007  eweb     Was nesting history in banner.
#  9th May 2007  eweb     Handle templates.
#  6th Jul 2007  eweb     #0008 Determine version numbers from buildno.h
#  6th Jul 2007  eweb     #0008 handle addcomment.pl
# 12th Sep 2007  eweb     #0008 Was removing the call to updateConfig.
# 19th Sep 2007  eweb     #0008 Company and Start Year.
# 17th Jan 2008  eweb     #0008 Generic handling
# 17th Jan 2008  eweb     #0008 Need to quotemeta on pattern.
#  9th May 2008  eweb     #0008 template comments go before the vars
# 18th Jun 2008  eweb     #0008 Map fictional 80000 bug numbers.
# 24th Jul 2008  eweb     #0008 Restrict changes to history section
# 19th Sep 2008  eweb     #0008 handle html and css
#  2nd Oct 2008  eweb     #0008 Preserve format of updateConfig
#  2nd Oct 2008  eweb     #0008 Not yet handling html
# 21st Nov 2008  eweb     #0008 Handle jsp(f), htm(l) and xml
#  1st Dec 2008  eweb     #0008 Map usernames
# 15th Jan 2009  eweb     #0008 Format of history
# 20th Jan 2009  eweb     #0008 Handle .def files, #???? Lint to #00007 Lint
# 21st Jan 2009  eweb     #0008 Formating history & Copyright
#  4th Mar 2009  eweb     #0008 End history with an empty comment
#  8th Apr 2009  eweb     #0008 Handle asps
# 16th Apr 2009  eweb     #0008 handle .rul files
# 28th May 2009  eweb     #0008 Respect number of question marks
#  2nd Nov 2009  eweb     #0008 Start year, .bas files
#  4th Dec 2009  eweb     #0008 Handle .properties, check banner
#  9th Dec 2009  eweb     #0008 xslt, fixing banner, detecting filename mismatches
# 17th Dec 2009  eweb     #0008 Checking File:addcomment.rb updateConfig, changed but no banner nor history
# 17th Dec 2009  eweb     #0008 fixing banner
# 14th Jan 2010  eweb     #0008 Handle .g, different message for directories
# 23rd Feb 2010  eweb     #0008 allow filename to be preceded by parent, .dtd files
# 18th Mar 2010  eweb     #0008 Don't change File: addcomment.rb it uses a variable
# 29th Mar 2010  eweb     #0008 Handle .jmx, don't add empty comments
# 20th May 2010  eweb     #0008 Avoid adding our copyright to yui files
# 20th May 2010  eweb     #0008 Had messed up copyright year
# 27th May 2010  eweb     #0008 Don't warn on IncrementalUpgrade mismatch
#  1st Jun 2010  eweb     #0008 Handle .vb files
# 23rd Jun 2010  eweb     #0008 Problems if banner but no history with single line comments
# 28th Jun 2010  eweb     #0008 Handle calls to updateConfig that only specify M.N.P
# 28th Jul 2010  eweb     #0008 Missing ]
#  8th Aug 2010  eweb     #0008 .idl files
# 19th Aug 2010  eweb     #0004 Known issue numbers
#  2nd Sep 2010  eweb     #0008 Handling use File::*
# 17th Sep 2010  eweb     #0008 Detect tabs and trailing spaces
# 29th Sep 2010  eweb     #0008 Handle .tld files
#  1st Nov 2010  eweb     #0008 Preserve bom
# 30th Nov 2010  eweb     #0008 Detect extended characters
#  9th Dec 2010  eweb     #0008 Call chevent, start year from version 0
# 17th Dec 2010  eweb     #0008 addcomment: chevent when not handled, -E to just chevent
#  6th Jan 2011  eweb     #0008 Ignore extended chars in foreign resource files
# 11th Jan 2011  eweb     #0008 Map usernames for original author
# 14th Jan 2011  eweb     #0008 perforce
#  3rd Feb 2011  eweb     #0008 Handle .xsd files
# 27th May 2011  eweb     #0008 UpdateConfig special cases
# 17th Jun 2011  eweb     #0008 Escape comment when searching
# 27th Jul 2011  eweb     #0008 check comments
# 12th Aug 2011  eweb     #0008 Ruby scripts
# 27th Oct 2011  eweb     #0008 NeoLogic Copyright
#  3rd Nov 2011  eweb     #0008 Handle .properties.default
#  6th Jan 2012  eweb     #0008 Update version in header
#  6th Feb 2012  eweb     #0008 No Dodgy character warning in utf-8 files
#  6th Feb 2012  eweb     #0008 File type detection
# 29th May 2012  eweb     #0008 Added to git
# 19th Jul 2012  eweb     #0008 Strip trailing spaces
# 19th Jul 2012  eweb     #0008 Remove wbt specifics
# 19th Jul 2012  eweb     #0008 Handle shebang line
# 19th Jul 2012  eweb     #0008 Eoln messages dependant on os
#  5th Aug 2012  eweb     #0008 Retains permissions
#  6th Aug 2012  eweb     #0008 Find git
#  6th Aug 2012  eweb     #0008 Reverse sort git commit message
# 10th Sep 2012  eweb     #0008 Treate .feature files as ruby
# 24th Oct 2012  eweb     #0008 Extended characters
#  5th Nov 2013  eweb     #0008 Port to ruby
#  5th Nov 2013  eweb     #0008 Shebang line to determine type
# 29th Nov 2013  eweb     #0008 Problems with multi line start
# 29th Nov 2013  eweb     #0008 Recognise ruby encoding
# 24th Jun 2014  eweb     #0008 feedback, file extensions, line numbers, regexps
# 26th May 2015  eweb     #0008 Handle sh/bash scripts
# 27th May 2015  eweb     #0008 applescript and files names with spaces
#  7th Sep 2015  eweb     #0007 brackets
#  7th Sep 2015  eweb     #0008 drive to git_root
# 19th Oct 2015  eweb     #0008 Qstream doesn't want issue numbers
# 14th Mar 2016  eweb     #0008 detect encoding
# 29th Dec 2016  eweb     #0008 .metrics as ruby
# 28th Oct 2017  eweb     #0008 tidy up
# 19th Nov 2017  eweb     #0008 treat lyt files as pl
#  2nd Apr 2018  eweb     #0008 don't write to git gui msg
#  2nd Apr 2018  eweb     #0007 convert to class
#  3rd Apr 2018  eweb     #0007 split into methods
#  3rd Apr 2018  eweb     #0007 rubocop
#  6th Apr 2018  eweb     #0008 assume xml are utf-8
#  6th Apr 2018  eweb     #0007 rubocop
#  7th Apr 2018  eweb     #0007 rubocop
# 19th Jul 2018  eweb     #0008 exclude bb.yaml
# 19th Jul 2018  eweb     #0008 orig_author and start_year from git
#  1st Jan 2019  eweb     #0008 spreadsheets
#  1st Jan 2019  eweb     #0008 percents in comments
#  1st Jan 2019  eweb     #0008 spaces in filenames
#  1st Jan 2019  eweb     #0008 error reporting
# 27th Feb 2019  eweb     #0008 Using multi line start as prefix
#  7th Aug 2019  eweb     #0008 Dockerfile as rb
#  7th Aug 2019  eweb     #0007 rubocop
#  1st Sep 2019  eweb     #0008 frozen string comment
# 19th Dec 2019  eweb     #0008 handle sh files
#  9th May 2021  eweb     #0008 treat .m as .cpp
# 12th Sep 2021  eweb     #0008 don't create .old
# 15th Dec 2021  eweb     #0008 files to ignore
#  1st Apr 2022  eweb     #0008 file not found
# 17th Apr 2023  eweb     #0007 rubocop
# 17th Apr 2023  eweb     #0007 input & output
#  1st May 2023  eweb     #0008 Makefiles
# 24th Nov 2024  eweb     #0008 handle dart files
#  6th Jan 2025  eweb     #0008 ignore jar files, downcase encoding
# 16th Jan 2025  eweb     #0008 handle frozen sting in separate comment block
# 18th Jan 2025  eweb     #0008 ignore .idea folder
#  6th Oct 2025  eweb     #0008 handle swift files
# 17th Jan 2026  eweb     #0008 add support for python
#

# DONE change event if comment not present.
# DONE validate comments
# DONE html and xml need banner after doctype / xml declaration
# TODO #00008 allow extended chars in xml if marked as utf-8.
# TODO #00008 check file type.

#
# Open the file.
# Scan header for copyright
# update year if necessary

# scan for history block
# append comment line to history

class String
  def blank?
    empty?
  end

  def present?
    !empty?
  end
end

class NilClass
  def blank?
    true
  end

  def present?
    false
  end
end

class Integer
  def ordinal
    if (11..13).cover?(abs % 100)
      'th'
    else
      case abs % 10
      when 1
        'st'
      when 2
        'nd'
      when 3
        'rd'
      else
        'th'
      end
    end
  end

  def ordinalize
    "#{self}#{ordinal}"
  end
end

class CommentAdder # rubocop:disable Metrics/ClassLength
  def initialize
    @use_clearcase = true
    @scc = :clearcase
    @change_event = 'N'

    @validate_comments = true
    @strip_trailing_spaces = true
    @tabs_allowed = false

    @opts = {}
  end

  def name_exceptions
    %w[schemaupgrade incrementalupgrade revisionnumber databaseversion baseschema topclassusername]
  end

  def data_exceptions
    %w[incrementalupgrade revisionnumber databaseversion topclassusername]
  end

  def getopts(str, opts)
    valid_opts = {}
    prev = nil
    str.chars do |ch|
      if ch == ':'
        valid_opts[prev] = true
      else
        valid_opts[prev = ch] = nil
      end
    end
    keep = []
    prev = nil
    ARGV.each do |arg|
      if prev
        opts[prev] = arg.dup
        prev = nil
      elsif arg[0] == '-'
        cmd = arg[1]
        if valid_opts.key?(cmd)
          prev = valid_opts[cmd] ? cmd : nil
          opts[cmd] = true
        else
          return false
        end
      else
        keep << arg
      end
    end
    ARGV.clear
    ARGV.concat(keep)
    true
  end

  def find_git
    dir = Dir.getwd
    until File.directory?("#{dir}/.git")
      parent = "#{dir}/.."
      if File.expand_path(dir) == File.expand_path(parent)
        break
      end

      dir = parent
    end
    dir = File.expand_path(dir)
    if File.directory?("#{dir}/.git")
      print "Found git at #{dir}\n" if @verbose
      @git_root = dir
      return 1
    end
    nil
  end

  def verify_clearcase
    if @verified_clearcase == 'N' && @use_clearcase
      topclass_vob = '/topclass'
      if RUBY_PLATFORM == 'linux'
        topclass_vob = "/vobs#{topclass_vob}"
      end
      desc = `cleartool desc -fmt "[%m]" "#{topclass_vob}"`
      if desc == '[**null meta type**]'
        print "Not a clearcase drive\n"
        @use_clearcase = false
      elsif desc == '[directory version]'
        print "Is a clearcase drive\n"
        @use_clearcase = true
      elsif desc.blank?
        print "Looks like we don't have cleartool\n"
        @use_clearcase = false
      end
      @verified_clearcase = 'Y'
    end
  end

  def get_build_number(drive, file_type = nil)
    build = major = minor = point = 0

    build_no_file = "#{drive}/topclass/oracle/topclass/sources/buildno.h"
    unless File.exist? build_no_file
      version_info_file = "#{drive}/topclass/oracle/topclass/sources/versioninfo.h"
      if File.exist? version_info_file
        build_no_file = version_info_file
      else
        neo_build_no_file = "#{drive}/topclass/neo/sources/buildno.h"
        if File.exist? neo_build_no_file
          build_no_file = neo_build_no_file
        else
          version_info_file = "#{drive}/topclass/neo/sources/versioninfo.h"
          if File.exist? version_info_file
            build_no_file = version_info_file
          end
        end
      end
    end

    open(build_no_file).each_line do |line|
      case line
      when /#define BUILDNUMBER +([0-9]+)/
        build = $1
      when /#define MAJORREVISION +([0-9]+)/
        major = $1
      when /#define MINORREVISION +([0-9]+)/
        minor = $1
      when /#define POINTREVISION +([0-9]+)/
        point = $1
      end
    end

    build = format('%03d', build)

    [major, minor, point, build]
  rescue Errno::ENOENT
    if file_type == 'sql' && "#{major}#{minor}#{point}#{build}" == ''
      print "**** Cannot open file #{build_no_file} for reading\n"
    end
  end

  def chevent(_file, comment)
    return if comment.blank?

    if @scc == :git
      add_to_git_commit_msg(comment)
    end
  end

  def format_date(d, m, y)
    d = d.to_i
    th = d.ordinal
    if d < 10
      d = " #{d}"
    end

    "#{d}#{th} #{m} #{y}"
  end

  def format_today
    now = Time.new.localtime

    @year = now.year

    months = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]

    @month = months[now.month - 1]
    d = now.day

    format_date(d, @month, @year)
  end

  def setup_for_type(type)
    case type
    when 'c++', 'dart'
      @multi_line_start = '/*'
      @multi_line_end = '*/'
      @multi_line_prefix = '  '
    when 'applescript'
      @multi_line_start = '(*'
      @multi_line_end = '*)'
      @multi_line_prefix = '  '
      @tabs_allowed = true
    when 'xml'
      @multi_line_start = '<!--'
      @multi_line_end = '-->'
      @multi_line_prefix = '  '
      @very_first_line = /<?xml.*>/
    when 'pl', 'rb', 'yaml', 'py'
      @single_line = '#'
      @very_first_line = '#!'
    when 'tmpl'
      @single_line = '#'
    when 'lsp'
      @multi_line_start = '#|'
      @multi_line_end = '|#'
      @multi_line_prefix = '  '
      #@single_line = ";"
    when 'bat'
      @single_line = '::'
    when 'def'
      @single_line = ';'
    when 'jsp'
      @multi_line_start = '<%/*'
      @multi_line_end = '*/%>'
      @multi_line_prefix = '  '
    when 'html'
      @multi_line_start = '<!--'
      @multi_line_end = '-->'
      @multi_line_prefix = '  '
      @very_first_line = /<!DOCTYPE.*>/
    when 'asp'
      @multi_line_start = '<%'
      @multi_line_end = '%>'
      @multi_line_prefix = "' "
    when 'bas'
      @single_line = "'"
    when 'sql'
      @single_line = '--'
    when 'swift'
      @single_line = '//'
    end
  end

  def ignore_file?(file)
    %w[R.java bb.yaml github.yaml gitlab.yaml].include?(file)
  end

  def ignore_dir?(path)
    path.include?('/.idea')
  end

  def determine_type(file)
    return if @just_change_event

    if File.directory?(@infile)
      print "Don't comment directories\n"
    elsif File.symlink?(@infile)
      print "Don't comment symlinks\n"
    elsif file.end_with?('.png', '.icns')
      print "Can't comment images\n"
    elsif file.end_with?('.xlsx')
      print "Can't comment spreadsheets\n"
    elsif file.end_with?('.dsw', '.dsp', '.dat', '.jar')
      print "Unhandled file type #{file}\n"
    elsif ignore_file?(file)
      print "Ignoring file #{file}\n"
    elsif ignore_dir?(@path)
      print "Ignoring files in #{@path}\n"
    elsif file.end_with?('.cpp', '.h', '.m', '.rh', '.inc', '.js', '.c', '.rc', '.rc2', '.lnt', '.css', '.rul', '.g', '.java', '.idl')
      'c++'
    elsif file.end_with?('.xml', '.xslt', '.dtd', '.jmx', '.tld', '.xsd', '.jrxml')
      'xml'
    elsif file.end_with?('.sql')
      'sql'
    elsif file.end_with?('.yml', '.yaml')
      'yaml'
    elsif file.end_with?('.rb', '.feature', '.rake', '.reek', '.metrics', '.simplecov') ||
      file == 'Rakefile' ||
      file == 'Gemfile' ||
      file == 'Dockerfile'
      'rb'
    elsif file.end_with?('.dart')
      'dart'
    elsif file.end_with?('.pl', '.sh', '.zshrc', '.zlogin', '.properties', '.properties.default', '.lyt')
      'pl'
    elsif file == 'Makefile'
      @tabs_allowed = true
      'pl'
    elsif file.end_with?('.tmpl')
      'tmpl'
    elsif file.end_with?('.lsp')
      'lsp'
    elsif file.end_with?('.bat', '.cmd')
      'bat'
    elsif file.end_with?('.def', '.cmd')
      'def'
    elsif file.end_with?('.jsp', '.jspf')
      'jsp'
    elsif file.end_with?('.html', '.htm')
      'html'
    elsif file.end_with?('.asp')
      'asp'
    elsif file.end_with?('.bas', '.vb')
      'bas'
    elsif file.end_with?('.applescript')
      'applescript'
    elsif file.end_with?('.swift')
      'swift'
    else
      first_line = File.open(@infile) { |fh| fh.readline.chomp }
      case first_line
      when /^#!.+ruby/
        'rb'
      when /^#!.+python/
        'py'
      when /^#!.+perl/, /^#!.+bash/, /^#!.+sh/
        'pl'
      else
        print "Unhandled file type #{file}\n"
      end
    end
  end

  def quotemeta(str)
    (str || '').gsub(/([.|()\[\]{}+$*?^])/) { |ch| "\\#{ch}" }
  end

  def write_history(output)
    puts 'write_history'
    if @multi_line_start.present?
      output.puts @multi_line_start
    end
    write_date_author_comment(output)
    write_line(output)
    if @multi_line_start.present?
      output.puts @multi_line_end
    else
      output.puts @single_line
    end
    @changed = 1
  end

  def write_banner(output)
    if @orig_author == '-'
      # skip
    elsif @multi_line_start.present?
      output.print "#{@multi_line_start}\n"
      output.print "#{@multi_line_prefix} File: #{@file}\n"
      output.print "#{@multi_line_prefix} Author: #{@orig_author}\n"
      output.print "#{@multi_line_prefix} Copyright #{@company}, #{@start_year}-#{@year}\n"
      output.print "#{@multi_line_prefix} Contents:\n"
      output.print "#{@multi_line_end}\n"
    else
      if @file_type == 'rb'
        output.print "# frozen_string_literal: true\n"
        output.print "\n"
      end
      output.print "#{@single_line}\n"
      output.print "#{@single_line} File: #{@file}\n"
      output.print "#{@single_line} Author: #{@orig_author}\n"
      output.print "#{@single_line} Copyright #{@company}, #{@start_year}-#{@year}\n"
      output.print "#{@single_line} Contents:\n"
      output.print "#{@single_line}\n"
    end
  end

  def get_comment_line(d, a, c)
    pdac(comment_line_prefix, d, a, c)
  end

  def comment_line_prefix
    if @multi_line_prefix.present?
      @multi_line_prefix
    else
      @single_line
    end
  end

  def pdac(p, d, a, c)
    if c.blank?
      format("%<prefix>s %-14<date>s %-8<author>s\n", prefix: p, date: d, author: a)
    else
      format("%<prefix>s %-14<date>s %-8<author>s %<comment>s\n", prefix: p, date: d, author: a, comment: c)
    end
  end

  def write_date_author_comment(output)
    output.print get_comment_line('Date:', 'Author:', 'Comments:') # [addcomment.pl don't change]
  end

  def write_line(output)
    # don't add empty comment.
    if @comments.present?
      output.print get_comment_line(@date, @author, @comments) # [addcomment.pl don't change
    end
  end

  def quote_char(ch)
    return '\\r' if ch == '\r'
    return '\\n' if ch == '\n'
    return '\\t' if ch == '\r'

    ch
  end

  def setup_options
    print_verbose_2 "argv: #{ARGV}"

    # Was anything other than the defined option entered on the command line?
    if !getopts('c:a:A:C:D:Eiom:n:p:b:k:S:v:x:tT:', @opts) || ARGV.size > 1
      $stderr.print "Unknown args #{ARGV}\n" unless ARGV.empty?
      # Usage()
      exit
    end

    print_verbose_2 "argv: #{ARGV}"
    print_verbose_2 "opts: #{@opts}"

    @git_root = '.'

    if find_git
      @scc = :git
      @drive = @git_root
    else
      @cwd = Dir.getwd
      if @cwd['p4clients']
        @scc = :p4
      end
    end

    @year = nil

    @date = format_today

    @infile = ARGV[0]

    if @infile.blank?
      raise "No file given\n"
    end

    unless File.exist?(@infile)
      raise "File '#{@infile}' not found\n"
    end

    if @opts.key?('c')
      @comments = @opts['c']
    end

    if @opts.key?('a')
      @author = @opts['a']
    end

    if @opts.key?('A')
      @orig_author = @opts['A']
    end

    if @opts.key?('E')
      @just_change_event = 1
    end

    if @opts.key?('D')
      if @opts['D'] =~ /([0-9]+)-(...)-([0-9]+)/
        @date = format_date($3, $2, $1)
      else
        print "ERROR invalid date @opts['D'] should be in form yyyy-mmm-dd e.g. 2011-Aug-12\n"
      end
    end

    if @opts.key?('C')
      @company = @opts['C']
    end

    if @opts.key?('i')
      @check_in = 'Y'
    end

    if @opts.key?('x')
      @change_event = @opts['x'].upcase
    end

    @verbose = @opts['v'].to_i if @opts['v']

    if @opts.key?('o')
      @check_out = 'Y'
    end

    if @opts.key?('m')
      @major = @opts['m']
    end

    if @opts.key?('n')
      @minor = @opts['n']
    end

    if @opts.key?('p')
      @point = @opts['p']
    end

    if @opts.key?('b')
      @build = @opts['b']
    end

    if @opts.key?('k')
      @package = @opts['k']
    end

    if @opts.key?('S')
      @start_year = @opts['S']
    end

    if @opts.key?('T')
      @file_type = @opts['T']
    end

    @abs_path = File.expand_path(@infile)
    @drive = if @abs_path =~ /^(.:)/
               $1
             else
               @git_root
             end

    @outfile = "#{@infile}.new"

    username_map = {}

    unless @author
      @author ||= ENV['USER'].downcase
      @author ||= ENV['USERNAME'].downcase
      if username_map[@author].present?
        @author = username_map[@author]
      end
    end
    if @orig_author.blank?
      case @scc
      when :clearcase
        @orig_author = `cleartool desc -fmt "%u" @infile@@/main/0`
      when :git
        @orig_author = `git log --pretty=format:"%ae" --follow --diff-filter=A "#{@infile}"`
      end
      if username_map[@orig_author].present?
        @orig_author = username_map[@orig_author]
      end
    end
    if @orig_author.blank?
      @orig_author = @author
    elsif @orig_author == '.'
      @orig_author = ''
    end

    if @company.blank?
      if @scc == :git
        @email = `git config --get user.email`
        if @email.end_with?('wbtsystems.com')
          @company = 'WBT Systems'
        end
        if @email.end_with?('qstream.com')
          @company = 'Qstream'
        end
      end
      @company ||= 'eweb'
    end
    if @start_year.blank?
      case @scc
      when :clearcase
        date = `cleartool desc -fmt "%Nd" @infile@@/main/0`
      when :git
        date = `git log --pretty=format:"%ai" --follow --diff-filter=A "#{@infile}"`
      end

      if date =~ /(^[0-9]{4})/
        @start_year = $1
      end
    end
    if @start_year.blank?
      @start_year = @year
    end
  end

  def main
    setup_options

    @infile = File.expand_path(@infile)

    @file = File.basename(@infile)
    @path = File.dirname(@infile)

    print_verbose_2 "(#{@file}, #{@path})\n"

    # strip trailing slash
    @path.sub!(%r{/$}, '')
    @path.sub!(%r{\\$}, '')

    # print "(@file, @path)\n"

    @parent = File.dirname(@path)

    @comments.strip! if @comments

    if @validate_comments
      if @comments =~ /^#[0-9]{4,5} .+/ || @comments =~ /^#[A-Z]+-[0-9]{3,5} .+/
        @comments = @comments.split(/ +/).join(' ')
      elsif @comments.blank?
        puts 'Empty comment'
      elsif @comments.match?(/^#\?+/)
        raise 'ERROR: Invalid comment'
      else
        raise 'ERROR: Invalid comment' unless @company == 'Qstream'
      end
    end

    if @opts['t']
      add_to_git_commit_msg(@comments)
      exit
    end

    @file_type ||= determine_type(@file)
    if @file_type.nil?
      if @change_event == 'Y'
        chevent(@infile, @comments)
      end
      exit
    end
    setup_for_type(@file_type)

    print_verbose_2 "File: #{@file} is of type #{@file_type}"

    File.open(@infile, 'r') do |input|
      File.open(@outfile, 'w') do |output|
        @changed = false
        @in_history = false
        @past_history = false
        @n_comments = 0
        @has_comment = false
        @commented = false
        @has_banner = false
        @has_history = false

        @comment_pattern = Regexp.new([quotemeta(@date), quotemeta(@author), quotemeta(@comments)].join(' +')) # [addcomment.pl don't change]

        print_verbose_2 "@comment_pattern [#{@comment_pattern}]\n"

        (@major, @minor, @point, @build) = get_build_number(@drive, @file_type)

        process_lines(input, output)
      end
    end
    write_results
  rescue StandardError => e
    puts "Error processing file #{@file || @infile}: #{e}"
    # raise
  end

  def process_lines(input, output)
    @dodgy_banner = false
    @comment_start = nil
    @comment_end = nil
    @line = 0
    @in_comment = nil
    @line_type = nil

    @previous_line = nil
    input.each_line do |this_line|
      start_of_header_line = Regexp.escape(@single_line || @multi_line_start)
      handle_encoding(this_line)
      handle_very_first_line(this_line)

      @line += 1

      print "#{@line}: #{this_line}" if @verbose.to_i > 4
      handle_eolns(this_line)
      handle_tabs_and_spaces(this_line)
      handle_extended_chars(this_line)
      handle_80000s(this_line)

      detect_comments(this_line)

      changeable = !this_line["[addcomment.pl don't change]"] # [addcomment.pl don't change]
      if changeable && !@past_history && this_line =~ /(.*)Copyright(.*)(\w+)(.*)([0-9][0-9]+)-([0-9][0-9]+)(.*)/
        copyright_year_range(output, this_line)
      elsif changeable && !@past_history && this_line =~ /(.*)Copyright(.*)(\w+)(.*)([0-9][0-9]+)(.*)/
        copyright_single_year(output, this_line)
      elsif changeable && !@past_history && this_line =~ /Date.*Author.*/
        date_author_line(output, this_line)
      elsif changeable && !@past_history && this_line =~ /date.*author.*comment.*/
        date_author_comment_line(output, this_line)
      elsif !@past_history && this_line['-- Revision History']
        revision_history_line(output, this_line)
      elsif !@past_history && this_line =~ @comment_pattern
        print_verbose_2 "Found comment_pattern\n#{this_line}"
        if @in_history
          # already commented
          @has_comment = true
        end
        output.print this_line
      elsif !@past_history && this_line =~ /^#{start_of_header_line}\s*File\s*:\s*(.+)\s*$/
        file_line(output, this_line, $1.strip)
      elsif !@past_history && this_line =~ / Version\s*:\s*([^\s]+)/
        version_line(output, this_line, $1)
      elsif !@past_history && end_of_comments?(this_line)
        end_of_comments(output, this_line)
      elsif @file_type == 'sql' && this_line =~ /updateConfig\s*\(\s*'(.+)',\s*'([.0-9]+)'\s*\)/i
        oracle_update_config(output, this_line, $1, $2)
      elsif @file_type == 'sql' && this_line =~ /updateConfig\s*(N?)'(.+)',\s*(N?)'([.0-9]+)'\s*/i
        sql_server_update_config(output, this_line, $2, $4, $1, $3)
      else
        # print "lala\n"
        if @in_history && !@past_history
          history_line(this_line)
        end
        output.print this_line
      end
      @previous_line = this_line
    end

    display_state
  end

  def handle_encoding(this_line)
    if @line == 0
      if this_line["\xef\xbb\xbf"]
        @bom = 1
      end
      if this_line =~ /<\?xml .+encoding='(.+)'.*\?>/
        @encoding = $1.downcase
      end
      if this_line =~ /<\?xml .+encoding="(.+)".*\?>/
        @encoding = $1.downcase
      end
      if @file_type == 'xml'
        @encoding ||= 'utf-8'
      end
      if this_line =~ /# -\*- coding: (.+) -\*-/
        @encoding = $1.downcase
      end
      if this_line =~ /# coding: (.+)/
        @encoding = $1.downcase
      end
    end
  end

  def handle_very_first_line(this_line)
    if @line == 0 && @very_first_line && this_line =~ Regexp.new(@very_first_line)
      @first_line = "#{this_line}\n"
    end
  end

  def handle_eolns(this_line)
    if this_line =~ /[^\r\n]*([\r\n]+)$/
      @eoln = $1
      if @eoln != @line_type
        if @line > 1
          $stderr.print "ERROR: Mixed line endings at line #{@file}:#{@line}\n"
        end
        @chars = @eoln.chars.collect(&:ord)
        #$stderr.print "eoln: [#{@chars}]\n"
        case @eoln
        when "\r\n"
          $stderr.print "ERROR: Dos line end [#{@chars}] at line #{@file}:#{@line}\n" unless RUBY_PLATFORM == 'MSWin32'
        when "\n"
          $stderr.print "ERROR: Unix line end [#{@chars}] at line #{@file}:#{@line}\n" if RUBY_PLATFORM == 'MSWin32'
        when "\r"
          $stderr.print "ERROR: Mac line end [#{@chars}] at line #{@file}:#{@line}\n"
        when "\r\r\n"
          $stderr.print "ERROR: Netscape line end [#{@chars}] at line #{@file}:#{@line}\n"
        else
          $stderr.print "ERROR: Odd line end [#{@chars}] at line #{@file}:#{@line}\n"
        end
        @line_type = @eoln
        this_line.gsub!(/[\r\n]/, '')
        this_line << "\n"
      end
    else
      $stderr.print "#{@file}:#{@line} No eoln at eof\n"
    end
  end

  def handle_tabs_and_spaces(this_line)
    if !@tabs_allowed && this_line["\t"]
      $stderr.print "TABS!!! Tabs found at line #{@file}:#{@line}\n"
    end
    if this_line.match?(/[ \t][\r\n]/)
      if @strip_trailing_spaces
        $stderr.print "Space! Trailing space removed from line #{@file}:#{@line}\n"
        this_line.sub!(/[ \t]+$/, '')
        @changed = 1
      else
        $stderr.print "SPACE!!! Trailing space found at line #{@file}:#{@line}\n"
      end
    end
  end

  def handle_extended_chars(this_line)
    if this_line =~ /([^\x20-\x7f\t\n\r]+)/
      exchars = $1
      if @bom
        # ignore
      elsif @file_type == 'rb'
        # ignore
      elsif @file_type == 'py'
        # ignore
      elsif @encoding == 'utf-8'
        # ignore
      elsif @infile.match?(/resources_..\.properties/)
        # ignore
      elsif @infile.match?(/_.+\.dat/) && !@infile['english']
        # ignore
      else
        chars = exchars.bytes.collect { |b| format('%02X', b) }.join
        $stderr.print "#{@file}:#{@line} CHAR!!! extended character '#{exchars}' [#{chars}]\n"
      end
    end
  end

  def handle_80000s(this_line)
    if this_line =~ /#8[0-9?]{4}/ && !this_line["[addcomment.pl don't change]"] # [addcomment.pl don't change]
      $stderr.print "#{this_line}\n"
    end
  end

  def detect_comments(this_line)
    if @multi_line_start.present? && this_line.start_with?(@multi_line_start)
      print_verbose_2 "Found start of multiline\n#{this_line}"
      @in_comment = true
      @comment_start = this_line.dup
      # chomp(@comment_start)
      @comment_start.sub!(/[\r\n]+$/, '')
    elsif @multi_line_end.present? && this_line.end_with?(@multi_line_end)
      print_verbose_2 "Found end of multiline\n#{this_line}"
      @in_comment = nil
      @comment_end = this_line.dup
      # chomp(@comment_end)
      @comment_end.sub!(/[\r\n]+$/, '')

      if @has_banner && !@past_banner
        @past_banner = true
        if @comment_end != @multi_line_end
          print "#{@line}: dodgy end of banner\n[#{@comment_end}]\n[#{@multi_line_end}]\n"
          @dodgy_banner = true
        end
      elsif @single_line.present? && this_line.start_with?(@single_line)
        @in_comment = true
      elsif @single_line.present?
        @in_comment = nil
      end
    elsif @single_line.present? && this_line.start_with?(@single_line)
      @in_comment = true
    elsif @single_line.present?
      @in_comment = nil
    end
  end

  def end_of_comments?(this_line)
    ((@file_type == 'tmpl' && this_line =~ /^##var/) ||
      (@multi_line_end.present? && this_line =~ Regexp.new("#{Regexp.quote(@multi_line_end)}$")) ||
      (@single_line.present? && this_line =~ Regexp.new("^#{Regexp.quote(@single_line)}$")) ||
      (@single_line.present? && this_line =~ /^$/) ||
      (@single_line.present? && this_line !~ Regexp.new("^#{Regexp.quote(@single_line)}")))
  end

  def print_verbose_2(msg)
    print msg if @verbose.to_i > 2
  end

  def end_of_comments(output, this_line)
    if @n_comments < 2
      print_verbose_2 "found end of comments: #{this_line}"
    end
    @n_comments += 1
    print_verbose_2 "@n_comments: #{@n_comments} @prev_line: #{@previous_line}"
    if @n_comments == 2 && @previous_line =~ /# frozen_string_literal: true/
      @n_comments -= 1
    end
    # end of comment?
    if @in_history && !@has_comment
      print_verbose_2 "were in history && hasComment is false\n#{this_line}"
      @changed = true
      write_line(output)
      @in_history = false
      @past_history = true
      @commented = true
      #@has_comment = true
    elsif @in_history && @has_comment && !@commented
      print_verbose_2 "were in history && hasComment is true\n#{this_line}"
      @commented = true
      @past_history = true
    elsif @in_history
      print "were in history && hasComment but @commented\n#{this_line}" #
      #@commented = true
      #@past_history = true
    else
      print_verbose_2 "were not in history\n#{this_line}"
      if @single_line.present? && @n_comments > 3
        print "ERROR: no history\n#{this_line}"
        @past_history = true
      end
    end
    output.print this_line
  end

  def version_line(output, this_line, version)
    print_verbose_2 "Found Version: version\n#{this_line}"
    mnpb = '@major.@minor.@point.@build'
    if version == mnpb
      output.print this_line
    else
      print "******* ERROR: version != mnpb\n"
      this_line.sub!(version, mnpb)
      output.print this_line
      @changed = true
    end
    # elsif  !@past_history && /<\?xml/ && @file_type == "xml"
    #  print_verbose_2 "Found '<?xml..> line\n#{this_line}"
    #  #print "Found ?xml\n"
    #  @pre_banner = this_line
  end

  def file_line(output, this_line, file)
    print_verbose_2 "Found File: #{file}\n#{this_line}"
    if this_line['use File::'] || file == @file || file == "#{@parent}/#{@file}" || file.match?(/^%.+%$/)
      output.print this_line
    elsif (file['/'] || file['\\']) && file != "#{@parent}/#{@file}"
      # but is it equal to directory/file?
      print "******* ERROR: #{file} != #{@parent}/#{@file}\n"
      this_line.sub!(file, "#{@parent}/#{@file}")
      output.print this_line
      @changed = true
    elsif file != @file
      # but is it equal to directory/file?
      print "******* ERROR: #{file} != #{@file}\n"
      this_line.sub!(file, @file)
      output.print this_line
      @changed = true
    end
  end

  def date_author_line(output, _this_line)
    # found start of history...
    print_verbose_2 "Found start of history\n"
    @in_history = true
    @has_history = true
    write_date_author_comment(output)
  end

  def date_author_comment_line(output, _this_line)
    # found start of history...
    print_verbose_2 "Found start of history (2)\n"
    @in_history = true
    @has_history = true
    @changed = true
    write_date_author_comment(output)
  end

  def revision_history_line(output, this_line)
    print_verbose_2 "Found 'Revision History' line\n#{this_line}"
    @in_history = true
    @has_history = true
    @changed = true
    write_date_author_comment(output)
  end

  def display_state
    if @verbose.to_i > 2
      puts "changed: #{@changed}"
      puts "in_history: #{@in_history}"
      puts "past_history: #{@past_history}"
      puts "n_comments: #{@n_comments}"
      puts "has_comment: #{@has_comment}"
      puts "commented: #{@commented}"
      puts "has_banner: #{@has_banner}"
      puts "has_history: #{@has_history}"
      puts "dodgy_banner: #{@dodgy_banner}"
    end
  end

  def history_line(this_line)
    case this_line
    when /\s+([0-9]+)(st|nd|rd|th)?\s+([A-Za-z]+)\s([0-9]+)\s+([a-zA-Z']+)\s+(.*)$/ #'
      d, _th, m, y, u, c = $1, $2, $3, $4, $5, $6
      c.sub!(/^(#\?{5}?) Lint/i, '#00007 Lint')
      c.sub!(/^(#\?{4}?) Lint/i, '#0007 Lint')
      c.sub!(/^Lint/i, '#0007 Lint')
      c.sub!(/^(#\?+) MSVC 8/i, '#10544 MSVC 8')
      c.sub!(/^(#\?+) CUpdater/i, '#9528 CUpdater')
      c.sub!(/^(#\?+) [- :]+/i, '$1 ')
      date = format_date(d, m, y)
      new_comment = get_comment_line(date, u, c)
      if this_line != new_comment
        print_verbose_2 "Old1:#{this_line}"
        print_verbose_2 "new1:#{new_comment}"
        this_line.clear
        this_line << new_comment
      end
    when /(\s{10,})(.+)$/
      c = $2
      c.sub!(/^(#\?{5}?) Lint/i, '#00007 Lint')
      c.sub!(/^(#\?{4}?) Lint/i, '#0007 Lint')
      c.sub!(/^Lint/i, '#0007 Lint')
      c.sub!(/^(#\?+) MSVC 8/i, '#10544 MSVC 8')
      c.sub!(/^(#\?+) CUpdater/i, '#9528 CUpdater')
      c.sub!(/^(#\?+) [- :]+/i, '$1 ')
      new_comment = get_comment_line('', '', c)
      if this_line != new_comment
        print_verbose_2 "Old2:#{this_line}"
        print_verbose_2 "new2:#{new_comment}"
        this_line.clear
        this_line << new_comment
      end
    else
      print "Comment:#{this_line}"
    end
  end

  def copyright_single_year(output, this_line)
    this_line =~ /(.*)Copyright(.*)(\w+)(.*)([0-9][0-9]+)(.*)/
    print_verbose_2 "Found copyright2\n#{this_line}"
    x1, x2, x3, x4, x5, x6 = $1, $2, $3, $4, $5, $6
    if !@in_comment
      print "Found copyright out of comment line\n#{this_line}"
      output.print this_line
    elsif this_line['Yahoo! Inc.']
      @orig_author = '-'
      print "Not updating, #{this_line}"
      print_verbose_2 "1: #{x1} 2: #{x2} 3: #{x3} 4: #{x4} 5: #{x5} 6: #{x6}\n"
      @has_banner = true
      output.print this_line
    elsif @orig_author == '-'
      print "Found copyright but not updating\n#{this_line}"
      print_verbose_2 "1: #{x1} 2: #{x2} 3: #{x3} 4: #{x4} 5: #{x5} 6: #{x6}\n"
      @has_banner = true
      output.print this_line
    else
      print_verbose_2 "Found copyright line\n#{this_line}"
      print_verbose_2 "1: #{x1} 2: #{x2} 3: #{x3} 4: #{x4} 5: #{x5} 6: #{x6}\n"
      @has_banner = true
      scanned_year = x5
      correct_year = @year
      if this_line['NeoLogic']
        correct_year = 1997
      end
      if scanned_year != correct_year
        @changed = true
      end
      output.print "#{x1}Copyright#{x2}#{x3}#{x4}#{x5}-#{correct_year}#{x6}\n"
      if @multi_line_start.present? && @comment_start != @multi_line_start
        print "#{@line}: dodgy start of banner\n[#{@comment_start}]\n[#{@multi_line_start}]\n"
        @dodgy_banner = true
      end
    end
  end

  def copyright_year_range(output, this_line)
    this_line =~ /(.*)Copyright(.*)(\w+)(.*)([0-9][0-9]+)-([0-9][0-9]+)(.*)/
    x1, x2, x3, x4, x5, x6, x7 = $1, $2, $3, $4, $5, $6, $7
    print_verbose_2 "Found copyright1\n#{this_line}"
    if !@in_comment
      print "Found copyright out of comment line\n#{this_line}"
      output.print this_line
    elsif this_line['Yahoo! Inc.']
      print_verbose_2 "Found Yahoo copyright\n#{this_line}"
      @orig_author = '-'
      print "Not updating, #{this_line}"
      print_verbose_2 "1: #{x1} 2: #{x2} 3: #{x3} 4: #{x4} 5: #{x5} 6: #{x6} 7: #{x7}\n"
      @has_banner = true
      output.print this_line
    elsif @orig_author == '-'
      print_verbose_2 "Found copyright but OrigAuthor is -\n#{this_line}"
      print "Found copyright but not updating\n#{this_line}"
      print_verbose_2 "1: #{x1} 2: #{x2} 3: #{x3} 4: #{x4} 5: #{x5} 6: #{x6} 7: #{x7}\n"
      @has_banner = true
      output.print this_line
    else
      print_verbose_2 "Found copyright line\n#{this_line}"
      print_verbose_2 "1: #{x1} 2: #{x2} 3: #{x3} 4: #{x4} 5: #{x5} 6: #{x6} 7: #{x7}\n"
      @has_banner = true
      scanned_year = x6
      correct_year = @year
      if this_line['NeoLogic']
        correct_year = 1997
      end
      if scanned_year != correct_year
        @changed = true
      end
      output.print "#{x1}Copyright#{x2}#{x3}#{x4}#{x5}-#{correct_year}#{x7}\n"
      if @multi_line_start.present? && @comment_start != @multi_line_start
        print "#{@line}: dodgy start of banner\n[#{@comment_start}]\n[#{@multi_line_start}]\n"
        @dodgy_banner = true
      end
    end
  end

  def sql_server_update_config(output, this_line, name, num, n1, n2)
    # EXECUTE updateConfig N'HELPER_VIEWS_PRE', N'7.3.0.008'
    # sql server call
    should_be = "#{@major}.#{@minor}.#{@point}.#{@build}#{@package}"

    filename = @file.sub(/(.+)\.sql/, '')

    lower_name = name.downcase

    if lower_name == 'IncrementalUpgrade'.downcase
      output.print this_line
    else
      if name_exceptions.include?(lower_name)
        # ignore
      elsif lower_name != filename.downcase
        print "****** ERROR: UpdateConfig #{name} != #{filename}\n"
      end
      if !data_exceptions.include?(lower_name) && num != should_be && should_be != '...'
        print "call to updateConfig( #{n1}'#{name}', #{n2}'#{num}' )\n"
        print "shouldBe updateConfig( #{n1}'#{name}', #{n2}'#{should_be}' )\n"
        this_line.sub!(num, should_be)
        output.print this_line
        @changed = true
      else
        output.print this_line
      end
    end
  end

  def oracle_update_config(output, this_line, name, num)
    # oracle call
    should_be = "#{@major}.#{@minor}.#{@point}.#{@build}#{@package}"

    filename = @file
    case filename
    when /(.+)_s\.sql/, /(.+)_b\.sql/, /(.+)\.sql/
      filename = $1
    end

    lower_name = name.downcase
    if lower_name == 'IncrementalUpgrade'.downcase
      output.print this_line
    else
      if name_exceptions.include?(lower_name)
        # skip
      elsif lower_name != filename.downcase
        print "****** ERROR: UpdateConfig #{name} != #{filename}\n"
      end
      if !data_exceptions.include?(lower_name) && num != should_be && should_be != '...'
        print "call to updateConfig( '#{name}', '#{num}' )\n"
        print "shouldBe updateConfig( '#{name}', '#{should_be}' )\n"
        this_line.sub!(num, should_be)
        output.print this_line
        @changed = true
      else
        output.print this_line
      end
    end
  end

  def write_results_inner(infile, banner, history)
    File.open(infile) do |input|
      # print "Will try to open @outfile\n"
      File.open(@outfile, 'w') do |output|
        if @first_line.present?
          output.print @first_line
        elsif @bom
          output.print "\xef\xbb\xbf"
        end
        write_banner(output) if banner
        write_history(output) if history
        line_no = 0
        input.each_line do |l|
          if line_no == 0
            l.gsub!(/\xef\xbb\xbf/, '')
          end
          if @first_line.blank? || line_no > 0
            output.print l
          end
          line_no += 1
        end
      end
    end
  end

  def write_results
    # had neither a banner nor a history
    if !@changed && !@has_banner && !@has_history
      puts '!@changed && !@has_banner && !@has_history'
      write_results_inner(@infile, true, true)
      # neither a history nor a banner but we updated something else?
    elsif @changed && !@has_banner && !@has_history
      puts '@changed && @has_banner && !@has_history'
      File.rename @outfile, "#{@outfile}.tmp"
      write_results_inner("#{@outfile}.tmp", true, true)
      File.unlink "#{@outfile}.tmp"
      # had a history which we updated but no banner
    elsif @changed && !@has_banner && @has_history
      File.rename @outfile, "#{@outfile}.tmp"
      write_results_inner("#{@outfile}.tmp", true, false)
      File.unlink "#{@outfile}.tmp"
      # had a banner but no history
    elsif @has_banner && !@has_history
      print_verbose_2 "Found hasBanner && !hasHistory\n"
      File.rename @outfile, "#{@outfile}.tmp"
      File.open("#{@outfile}.tmp", 'r') do |input|
        # print "Will try to open @outfile\n"
        File.open(@outfile, 'w') do |output|
          comments = 0
          written_history = false
          input.each_line do |l|
            if (@multi_line_end.present? && l =~ /^ *\Q@multi_line_end\E *$/) ||
              (@single_line.present? && l =~ /^ *\Q@single_line\E *$/)
              # print "end of comments\n"
              comments += 1
              # end of comment?
              output.print l
              if !written_history && (@single_line.blank? || comments == 2)
                write_history(output)
                written_history = true
              end
            else
              output.print l
            end
          end
        end
      end
      File.unlink "#{@outfile}.tmp"
      # had a dodgy banner
    elsif @dodgy_banner
      print "Fixing dodgy banner\n"
      @changed = true
      File.rename @outfile, "#{@outfile}.tmp"
      File.open("#{@outfile}.tmp", 'r') do |input|
        # print "Will try to open @outfile\n"
        File.open(@outfile, 'w') do |output|
          @past = false

          input.each_line do |l|
            l.chomp!
            if @past
              output.print "#{l}\n"
            elsif @multi_line_start.present? && l.start_with?(@multi_line_start)
              output.print "#{@multi_line_start}\n"
              print_verbose_2 "start of comments\n"
            elsif @multi_line_end.present? && l.end_with?(@multi_line_end)
              output.print "#{@multi_line_end}\n"
              @past = 1
              print_verbose_2 "end of comments\n"
            else
              print_verbose_2 "banner line\n"
              case l
              when /^\$ *$/
                # output.print "#{@multi_line_prefix} File: "#{$1}"\n"
              when Regexp.new("#{Regexp.quote(@multi_line_prefix)} *File: (.+)")
                output.print "#{@multi_line_prefix} File: #{$1}\n"
              when Regexp.new("#{Regexp.quote(@multi_line_prefix)} *Author: (.+)")
                output.print "#{@multi_line_prefix} Author: #{$1}\n"
              when Regexp.new("#{Regexp.quote(@multi_line_prefix)} *Contents: (.+)")
                output.print "#{@multi_line_prefix} Contents: #{$1}\n"
              when Regexp.new("#{Regexp.quote(@multi_line_prefix)} *Contents:")
                output.print "#{@multi_line_prefix} Contents:\n"
              when Regexp.new("#{Regexp.quote(@multi_line_prefix)} *Copyright (.+), (.+)")
                output.print "#{@multi_line_prefix} Copyright #{$1}, #{$2}\n"
              when Regexp.new("#{Regexp.quote(@multi_line_prefix)}( ?)(.+)")
                output.print "#{@multi_line_prefix} #{$2}\n"
              else
                output.print "#{l}\n"
              end
            end
          end
        end
      end
      File.unlink "#{@outfile}.tmp"
    end

    if !@changed && @commented
      print_verbose_2 "No change\n"
      File.unlink @outfile
    else
      print_verbose_2 "Changed\n"
      if @check_out == 'Y'
        CheckOut(@infile, @comments)
      end
      perm = File.stat(@infile).mode & 0o7777
      # File.rename @infile, "#{@infile}.old"
      File.unlink @infile
      File.rename @outfile, @infile
      File.chmod(perm, @infile)
      # perm = File.stat(@infile).mode & 0o7777
      if @check_in == 'Y'
        CheckIn(@infile, @comments)
      end
    end

    if @change_event == 'Y'
      chevent(@infile, @comments)
    end
  end

  def add_to_git_commit_msg(comment)
    puts caller
    gitmsg = "#{@git_root}/.git/GITGUI_MSG"
    comments = open(gitmsg).lines
    chomp comments
    unless comments.any? { |c| c.match(/\Q#{comment}\E/) }
      print_verbose_2 "Adding #{comment} to commit message\n"
      comments << comment
      comments = sort comments
      open(gitmsg, 'w') do |cmt|
        comments.reverse_each do |c|
          cmt.puts c
        end
      end
    end
  rescue StandardError => e
    print_verbose_2 "Error: failed to open #{gitmsg} #{e}\n"
  end
end

CommentAdder.new.main
