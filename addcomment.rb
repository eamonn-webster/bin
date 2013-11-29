#!/usr/bin/env ruby
#
# File: addcomment.rb
# Author: eweb
# Copyright eweb, 2003-2013
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

#use strict
#use File::Spec
#use Getopt::Std
#use File::Basename
#use Cwd
#use File::Temp

@verbose
@verified_clearcase
@use_clearcase = true
@cctool = "cleartool"
@scc = "clearcase"
@changeEvent = "Y"

@preBanner
@infile
@comments
@Author
@OrigAuthor
@Company
@CompanyX
@checkIn
@checkOut
@Major
@Minor
@Point
@Build
@Package
@StartYear
#@multi_line_start
#@multi_line_end
#@multi_line_prefix
@single_line
@very_first_line
@FirstLine
@bom
@encoding
@JustChangeEvent
@ValidateComments = true
@stripTrailingSpaces = true

@bug_map = {}

@nameExceptions = %w{schemaupgrade incrementalupgrade revisionnumber databaseversion baseschema topclassusername}
@dataExceptions = %w{incrementalupgrade revisionnumber databaseversion topclassusername}

class String
  def blank?
    self.empty?
  end

  def present?
    !self.empty?
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

@opts = {
=begin
 'a' => nil,
             'c' => nil,
             'E' => nil,
             'A' => nil,
             'C' => nil,
             'D' => nil,
             'i' => nil,
             'o' => nil,
             'm' => nil,
             'n' => nil,
             'p' => nil,
             'b' => nil,
             'k' => nil,
             'S' => nil,
             'v' => nil,
             'x' => nil,
             't' => nil,
=end
}

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
      if valid_opts.has_key?(cmd)
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

puts "argv: #{ARGV}" if @verbose.to_i > 2

# Was anything other than the defined option entered on the command line?
if (!getopts("c:a:A:C:D:Eiom:n:p:b:k:S:v:x:t", @opts) or ARGV.size > 1)
  STDERR.print "Unknown args #{ARGV}\n" if ARGV.size > 0
  #Usage()
  exit
end

puts "argv: #{ARGV}" if @verbose.to_i > 2
puts "opts: #{@opts}" if @verbose.to_i > 2

def find_git
  dir = Dir.getwd
  while (!File.directory?("#{dir}/.git"))
    parent = "#{dir}/.."
    if (File.expand_path(dir) == File.expand_path(parent))
      break
    end
    dir = parent
  end
  dir = File.expand_path(dir)
  if (File.directory?("#{dir}/.git"))
    print "Found git at #{dir}\n" if (@verbose)
    @git_root = dir
    return 1
  end
  nil
end

@git_root = "."

if (find_git())
  @scc = "git"
else
  @cwd = Dir.getwd
  if (@cwd =~ /p4clients/)
    @scc = "p4"
  end
end

def verifyClearcase
  if (@verified_clearcase == "N" and @use_clearcase)
    @cctool = "cleartool"
    @topclassVob = "/topclass"
    if (RUBY_PLATFORM == "linux")
      @topclassVob = "/vobs#{@topclassVob}"
    end
    desc = `#{@cctool} desc -fmt "[%m]" "#{@topclassVob}"`
    if (desc == "[**null meta type**]")
      print "Not a clearcase drive\n"
      @cctool = ""
      @use_clearcase = false
    elsif (desc == "[directory version]")
      print "Is a clearcase drive\n"
      @use_clearcase = true
    elsif (desc.blank?)
      print "Looks like we don't have cleartool\n"
      @cctool = ""
      @use_clearcase = false
    end
    @verified_clearcase = "Y"
  end
end

def GetBuildNumber(drive, fileType=nil)
  buildNoFile = "#{drive}/topclass/oracle/topclass/sources/buildno.h"
  if (!File.exists? buildNoFile)
    versionInfoFile = "#{drive}/topclass/oracle/topclass/sources/versioninfo.h"
    if (File.exists? versionInfoFile)
      buildNoFile = versionInfoFile
    else
      neoBuildNoFile = "#{drive}/topclass/neo/sources/buildno.h"
      if (File.exists? neoBuildNoFile)
        buildNoFile = neoBuildNoFile
      else
        versionInfoFile = "#{drive}/topclass/neo/sources/versioninfo.h"
        if (File.exists? versionInfoFile)
          buildNoFile = versionInfoFile
        end
      end
    end
  end

  #puts buildNoFile

  open(buildNoFile).each_line do |line|
    if (line =~ /\#define BUILDNUMBER +([0-9]+)/)
      @Build = $1
      #@Build++
      #@Build--
    elsif (line =~ /\#define MAJORREVISION +([0-9]+)/)
      @Major = $1
    elsif (line =~ /\#define MINORREVISION +([0-9]+)/)
      @Minor = $1
    elsif (line =~ /\#define POINTREVISION +([0-9]+)/)
      @Point = $1
    end
  end

  @Build = sprintf("%03d", @Build)

  [@Major, @Minor, @Point, @Build]
rescue Errno::ENOENT
  if (fileType == "sql" && "#{@Major}#{@Minor}#{@Point}#{@Build}#{@Package}" == "")
    print "**** Cannot open file #{buildNoFile} for reading\n"
  end

end

def chevent(file, comment)
  if (comment.blank?)
  elsif ($scc == "git")
    add_to_git_commit_msg(comment)
  end
end

@Year = nil

def formatDate(d, m, y)
  th = "th"
  d = d.to_i
  if (d == 1 || d == 21 || d == 31)
    th = "st"
  elsif (d == 2 || d == 22)
    th = "nd"
  elsif (d == 3 || d == 23)
    th = "rd"
  end
  if (d < 10)
    d = " #{d}"
  end

  "#{d}#{th} #{m} #{y}"
end

def FormatToday
  now = Time.new.localtime

  @Year = now.year

  months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

  @Month = months[now.month-1]
  d = now.day

  return formatDate(d, @Month, @Year)
end

@Date = FormatToday()

@infile = ARGV[0]

if @opts.has_key?('c')
  @comments = @opts['c']
end

if @opts.has_key?('a')
  @Author = @opts['a']
end

if @opts.has_key?('A')
  @OrigAuthor = @opts['A']
end

if @opts.has_key?('E')
  @JustChangeEvent = 1
end

if @opts.has_key?('D')
  if (@opts['D'] =~ /([0-9]+)-(...)-([0-9]+)/)
    @Date = formatDate($3, $2, $1)
  else
    print "ERROR invalid date @opts['D'] should be in form yyyy-mmm-dd e.g. 2011-Aug-12\n"
  end
end

if @opts.has_key?('C')
  @Company = @opts['C']
  @CompanyX = @opts['C']
end

if @opts.has_key?('i')
  @checkIn = "Y"
end

if @opts.has_key?('x')
  @changeEvent = uc @opts['x']
end

@verbose = @opts['v'].to_i if @opts['v']

if @opts.has_key?('o')
  @checkOut = "Y"
end

if @opts.has_key?('m')
  @Major = @opts['m']
end

if @opts.has_key?('n')
  @Minor = @opts['n']
end

if @opts.has_key?('p')
  @Point = @opts['p']
end

if @opts.has_key?('b')
  @Build = @opts['b']
end

if @opts.has_key?('k')
  @Package = @opts['k']
end

if @opts.has_key?('S')
  @StartYear = @opts['S']
end

@abs_path = File.expand_path(@infile)
@drive
if (@abs_path =~ /^(.:)/)
  @drive = $1
end

@outfile = "#{@infile}.new"

@usernameMap = {}

unless @Author
  @Author = ENV['USER'].downcase unless (@Author)
  @Author = ENV['USERNAME'].downcase unless (@Author)
  if (@usernameMap[@Author].present?)
    @Author = @usernameMap[@Author]
  end
end
if (@OrigAuthor.blank? and @scc == "clearcase")
  @OrigAuthor = `cleartool desc -fmt "%u" @infile\@\@/main/0`
  if (@usernameMap[@OrigAuthor].present?)
    @OrigAuthor = @usernameMap[@OrigAuthor]
  end
end
if (@OrigAuthor.blank?)
  @OrigAuthor = @Author
elsif (@OrigAuthor == ".")
  @OrigAuthor = ""
end

if (@Company.blank?)
  if (@scc == "git")
    @email = `git config --get user.email`
    if (@email =~ /wbtsystems.com/)
      @Company = "WBT Systems"
    end
    if (@email =~ /qstream.com/)
      @Company = "QStream"
    end
  end
  @Company = "eweb" unless (@Company)
end
if (@StartYear.blank? and @scc == "clearcase")
  @date = `cleartool desc -fmt "%Nd" @infile\@\@/main/0`
  if (@date =~ /(^[0-9]{4})/)
    @StartYear = $1
  end
end
if (@StartYear.blank?)
  if (@Company == "WBT Systems")
    @StartYear = "1995"
  else
    @StartYear = @Year
  end
end

if (@infile =~ %r{(/|\\)yui\1})
  #print "Part of yui\n"
  #@OrigAuthor = "-"
end

if (@infile.blank?)
  die "No file given\n"
end

# determine filename and immediate parent
#(@File, @path) = fileparse(@infile)

@infile = File.expand_path(@infile)

@File = File.basename(@infile)
@path = File.dirname(@infile)

print "(#{@File}, #{@path})\n" if @verbose.to_i > 2

# strip trailing slash
@path.sub!(%r{\/$}, '')
@path.sub!(%r{\\$}, '')

#print "(@File, @path)\n"

@Parent = File.dirname(@path)

@fileType = ""

@comments.strip! if @comments

if @ValidateComments
  if @comments =~ /^#[0-9]{4,5} .+/ || @comments =~ /^#[A-Z]+-[0-9]{3,5} .+/
    @comments = @comments.split(/ +/).join(' ')
  elsif @comments.blank?
    puts 'Empty comment'
  elsif @comments =~ /^#\?+/
    raise 'ERROR: Invalid comment'
  else
    raise 'ERROR: Invalid comment'
  end
end

if @opts['t']
  add_to_git_commit_msg(@comments)
  exit
end

def setup_for_type(type)
  case type
    when 'c++'
      @multi_line_start = "/*"
      @multi_line_end = "*/"
      @multi_line_prefix = "  "
    when 'xml'
      @multi_line_start = "<!--"
      @multi_line_end = "-->"
      @multi_line_prefix = "  "
      @very_first_line = /<?xml.*>/
    when 'pl'
      @single_line = "#"
      @very_first_line = "#!"
    when "tmpl"
      @single_line = "#"
    when "lsp"
      @multi_line_start = "#|"
      @multi_line_end = "|#"
      @multi_line_prefix = "  "
    #@single_line = ";"
    when "bat"
      @single_line = "::"
    when "def"
      @single_line = ";"
    when "jsp"
      @multi_line_start = "<%/*"
      @multi_line_end = "*/%>"
      @multi_line_prefix = "  "
    when "html"
      @multi_line_start = "<!--"
      @multi_line_end = "-->"
      @multi_line_prefix = "  "
      @very_first_line = /<!DOCTYPE.*>/
    when "asp"
      @multi_line_start = "<%"
      @multi_line_end = "%>"
      @multi_line_prefix = "' "
    when "bas"
      @single_line = "'"
  end
end

def determine_type(file)
  file_type = nil
  if @JustChangeEvent
  elsif (file =~ /\.dsw$/ or
      file =~ /\.dsp$/ or
      file =~ /\.dat$/)
    print "Unhandled file type #{file}\n"
  elsif (file == "R.java")
    print "Uncommentable file #{file}\n"
  elsif (file =~ /\.cpp$/ or
      file =~ /\.h$/ or
      file =~ /\.rh$/ or
      file =~ /\.inc$/ or
      file =~ /\.js$/ or
      file =~ /\.c$/ or
      file =~ /\.rc$/ or
      file =~ /\.rc2$/ or
      file =~ /\.lnt$/ or
      file =~ /\.css$/ or
      file =~ /\.rul$/ or
      file =~ /\.g$/ or
      file =~ /\.java$/ or
      file =~ /\.idl$/)
    file_type = "c++"
  elsif (file =~ /\.xml$/ or
      file =~ /\.xslt$/ or
      file =~ /\.dtd$/ or
      file =~ /\.jmx$/ or
      file =~ /\.tld$/ or
      file =~ /\.xsd$/ or
      file =~ /\.jrxml/)
    file_type = "xml"
  elsif (file =~ /\.sql$/)
    file_type = "sql"
  elsif (file =~ /\.rb$/ or
      file =~ /\.feature$/ or
      file =~ /\.pl$/ or
      file =~ /\.properties$/ or
      file =~ /\.properties.default$/ or
      file =~ /\.rake$/ or
      file =~ /^Rakefile$/ )
    file_type = "pl"
  elsif (file =~ /\.tmpl$/)
    file_type = "tmpl"
  elsif (file =~ /\.lsp$/)
    file_type = "lsp"
  elsif (file =~ /\.bat$/ or file =~ /\.cmd$/)
    file_type = "bat"
  elsif (file =~ /\.def$/ or file =~ /\.cmd$/)
    file_type = "def"
  elsif (file =~ /\.jsp$/ or file =~ /\.jspf$/)
    file_type = "jsp"
  elsif (file =~ /\.html$/ or file =~ /\.htm$/)
    file_type = "html"
  elsif (file =~ /\.asp$/)
    file_type = "asp"
  elsif (file =~ /\.bas$/ or file =~ /\.vb$/)
    file_type = "bas"
  elsif (File.directory?(@infile))
    print "Don't comment directories\n"
  else
    first_line = File.open(@infile) { |fh| fh.readline.chomp }
    if first_line =~ /^#!.+perl/ ||
        first_line =~ /^#!.+ruby/
      file_type = 'pl'
    else
      print "Unhandled file type #{file}\n"
    end
  end
  file_type
end

@fileType = determine_type(@File)
if @fileType.nil?
  if (@changeEvent == "Y")
    chevent(@infile, @comments)
  end
  exit
end
setup_for_type(@fileType)

puts "File: #{@File} is of type #{@fileType}" if @verbose.to_i > 2
#puts [@multi_line_start, @multi_line_end, @multi_line_prefix].join(', ')
#puts "#{@single_line} #{@very_first_line}"

#print "Will try to open @infile\n"
@input = open(@infile, 'r') or die "can't open #{@infile}\n"
# binmode @input
#print "Will try to open @outfile\n"
@output = open(@outfile, 'w') or die "can't open #{@outfile}\n"
#binmode @output

@changed = false
@inHistory = false
@pastHistory = false
@nComments = 0
@hasComment = false
@commented = false
@hasBanner = false
@hasHistory = false

def quotemeta(str)
  (str || '').gsub(/([.|()\[\]{}+\$*?^])/) { |ch| "\\#{ch}" }
end

@commentPattern = Regexp.new(quotemeta(@Date) + " +" + quotemeta(@Author) + " +" + quotemeta(@comments)) # [addcomment.pl don't change]

print "\@commentPattern [#{@commentPattern}]\n" if @verbose.to_i > 2

def writeHistory
  puts 'writeHistory'
  if (@multi_line_start.present?)
    @output.puts @multi_line_start
  end
  writeDAC
  writeLine
  if (@multi_line_start.present?)
    @output.puts @multi_line_end
  else
    @output.puts @single_line
  end
  @changed = 1
end

def writeBanner
  if @OrigAuthor == "-"
  else
    if @multi_line_start.present?
      @output.print "#{@multi_line_start}\n"
      @output.print "#{@multi_line_prefix} File: #{@File}\n"
      @output.print "#{@multi_line_prefix} Author: #{@OrigAuthor}\n"
      @output.print "#{@multi_line_prefix} Copyright #{@Company}, #{@StartYear}-#{@Year}\n"
      @output.print "#{@multi_line_prefix} Contents:\n"
      @output.print "#{@multi_line_end}\n"
    else
      @output.print "#{@single_line}\n"
      @output.print "#{@single_line} File: #{@File}\n"
      @output.print "#{@single_line} Author: #{@OrigAuthor}\n"
      @output.print "#{@single_line} Copyright #{@Company}, #{@StartYear}-#{@Year}\n"
      @output.print "#{@single_line} Contents:\n"
      @output.print "#{@single_line}\n"
    end
  end
end

def getCommentLine(date, author, comments)
  if (comments.blank?)
    if (@multi_line_start.present?)
      return sprintf "#{@multi_line_prefix} %-14s %s\n", date, author; # [addcomment.pl don't change]
    else
      return sprintf "#{@single_line} %-14s %s\n", date, author; # [addcomment.pl don't change]
    end
  else
    if (@multi_line_start.present?)
      return sprintf "#{@multi_line_prefix} %-14s %-8s %s\n", date, author, comments; # [addcomment.pl don't change]
    else
      return sprintf "#{@single_line} %-14s %-8s %s\n", date, author, comments; # [addcomment.pl don't change]
    end
  end
end

def writeDAC
  @output.print getCommentLine("Date:", "Author:", "Comments:"); # [addcomment.pl don't change]
end

def writeLine
  # don't add empty comment.
  if (@comments.present?)
    @output.print getCommentLine(@Date, @Author, @comments); # [addcomment.pl don't change
  end
end

def map_ids(line, changed, found80000)
  #print "line: #{line}\n"
  #print "changed: #{changed}\n"
  #print "found80000: #{found80000}\n"

  line.scan(/#([0-9]{4,5})[^0-9]/) do |id|
    #print "[#{id}]\n"
    if (id == "80000")
      found80000 = true
    end
    old_id = id
    new_id = @bug_map[old_id]
    if new_id
      print "changing from #{old_id} to #{new_id}\n"
      changed = 1
      line = line.gsub("##{old_id}", "##{new_id}")
    end
  end
  #print "line: #{line}\n"
  #print "changed: #{changed}\n"
  #print "found80000: #{found80000}\n"
  [line, changed, found80000]
end

(@Major, @Minor, @Point, @Build) = GetBuildNumber(@drive, @fileType)

@dodgyBanner
@pastBanner
@commentStart
@commentEnd
@Line = 0
@incomment
@trailingSpace
@tabs

@lineType

def quoteChar(ch)
  return "\\r" if (ch == '\r')
  return "\\n" if (ch == '\n')
  return "\\t" if (ch == '\r')
  return ch
end

@input.each_line do |thisLine|

  if (@Line == 0 and thisLine =~ /\xef\xbb\xbf/)
    @bom = 1
  end
  if (@Line == 0 and thisLine =~ /<\?xml .+encoding='(.+)'.*\?>/)
    @encoding = $1
  end
  if (@Line == 0 and thisLine =~ /<\?xml .+encoding="(.+)".*\?>/)
    @encoding = $1
  end
  if thisLine =~ /# -\*- coding: (.+) -\*-/
    @encoding = $1
  end

  if (@Line == 0 and @very_first_line && thisLine =~ Regexp.new(@very_first_line))
    @FirstLine = "#{thisLine}\n"
  end

  @Line += 1

  print "#{@Line}: #{thisLine}" if (@verbose.to_i > 4)
  if (thisLine =~ /[^\r\n]*([\r\n]+)$/)
    @eoln = $1
    if (@eoln != @lineType)
      if (@Line > 1)
        STDERR.print "ERROR: Mixed line endings at line #{@Line}\n"
      end
      @chars = @eoln.chars.collect(&:ord)
      #STDERR.print "eoln: [#{@chars}]\n"

      if (@eoln == "\r\n")
        STDERR.print "ERROR: Dos line end [#{@chars}] at line #{@Line}\n" unless (RUBY_PLATFORM == "MSWin32")
      elsif (@eoln == "\n")
        STDERR.print "ERROR: Unix line end [#{@chars}] at line #{@Line}\n" if (RUBY_PLATFORM == "MSWin32")
      elsif (@eoln == "\r")
        STDERR.print "ERROR: Mac line end [#{@chars}] at line #{@Line}\n"
      elsif (@eoln == "\r\r\n")
        STDERR.print "ERROR: Netscape line end [#{@chars}] at line #{@Line}\n"
      else
        STDERR.print "ERROR: Odd line end [#{@chars}] at line #{@Line}\n"
      end
    end
    @lineType = @eoln
    thisLine.gsub!(/[\r\n]/, '')
    thisLine = "#{thisLine}\n"
  else
    STDERR.print "#{@File}:#{@Line} No eoln at eof\n"
  end

  if (thisLine =~ /\t/)
    STDERR.print "TABS!!! Tabs found at line #{@Line}\n"
  end
  if (thisLine =~ /[ \t][\r\n]/)
    if (@stripTrailingSpaces)
      STDERR.print "Space! Trailing space removed from line #{@Line}\n"
      thisLine.sub!(/[ \t]+$/, '')
      @changed = 1
    else
      STDERR.print "SPACE!!! Trailing space found at line #{@Line}\n"
    end
  end
  if (thisLine =~ /([^\x20-\x7f\t\n\r]+)/)
    exchars = $1
    if (@bom)
    elsif (@encoding == "utf-8")
    elsif (@infile =~ /resources_..\.properties/)
    elsif (@infile =~ /_.+\.dat/ and @infile !~ /english/)
    else
      # print "[exchars] " . join(',', unpack('U*', exchars)) . "\n"
      chars = exchars.bytes.collect{|b| '%X' % b }.join
      #chars = exchars
      STDERR.print "#{@File}:#{@Line} CHAR!!! extended character '#{exchars}' [#{chars}]\n"
    end
  end
  (@newline, @bugchanged, @found80000) = map_ids(thisLine, 0, 0)
  if (@bugchanged)
    #print "mapped bug_id\n"
    @thisLine = @newline
    @changed = true
  end
  if (@thisLine =~ /#8[0-9?]{4}/ && @thisLine !~ /\[addcomment\.pl don\'t change\]/) # [addcomment.pl don't change]
    STDERR.print "#{@thisLine}\n"
  end

  if (@multi_line_start.present? && @thisLine.start_with?(@multi_line_start))
    print "Found start of multiline\n#{@thisLine}" if (@verbose.to_i > 2)
    @incomment = true
    @commentStart = @thisLine.dup
    #chomp(@commentStart)
    @commentStart.sub!(/[\r\n]+$/, '')
  elsif (@multi_line_end.present? && @thisLine.start_with?(@multi_line_end))
    print "Found end of multiline\n#{@thisLine}" if (@verbose.to_i > 2)
    @incomment = nil
    @commentEnd = @thisLine.dup
    #chomp(@commentEnd)
    @commentEnd.sub!(/[\r\n]+$/, '')

    if (@hasBanner and !@pastBanner)
      @pastBanner = true
      if (@commentEnd != @multi_line_end)
        print "#{@Line}: dodgy end of banner\n[#{@commentEnd}]\n[#{@multi_line_end}]\n"; # if ( @verbose.to_i > 2 )
        @dodgyBanner = true
      end
    end
  elsif (@single_line.present? and @thisLine.start_with?(@single_line))
    @incomment = true
  elsif (@single_line.present?)
    @incomment = nil
  end

  changeable = @thisLine !~ /\[addcomment\.pl don\'t change\]/ # [addcomment.pl don't change]
  if (changeable and !@pastHistory and @thisLine =~ /(.*)Copyright(.*)(\w+)(.*)([0-9][0-9]+)-([0-9][0-9]+)(.*)/)
    x1, x2, x3, x4, x5, x6, x7 = $1, $2, $3, $4, $5, $6, $7
    print "Found copyright1\n#{@thisLine}" if (@verbose.to_i > 2)
    if (!@incomment)
      print "Found copyright out of comment line\n#{@thisLine}"
      @output.print "#{@thisLine}"
    elsif (@thisLine =~ /Yahoo! Inc./)
      print "Found Yahoo copyright\n#{@thisLine}" if (@verbose.to_i > 2)
      @OrigAuthor = "-"
      print "Not updating, #{@thisLine}"
      print "1: #{x1} 2: #{x2} 3: #{x3} 4: #{x4} 5: #{x5} 6: #{x6} 7: #{x7}\n" if (@verbose.to_i > 2)
      @hasBanner = true
      @output.print "#{@thisLine}"
    elsif (@OrigAuthor == "-")
      print "Found copyright but OrigAuthor is -\n#{@thisLine}" if (@verbose.to_i > 2)
      print "Found copyright but not updating\n#{@thisLine}"
      print "1: #{x1} 2: #{x2} 3: #{x3} 4: #{x4} 5: #{x5} 6: #{x6} 7: #{x7}\n" if (@verbose.to_i > 2)
      @hasBanner = true
      @output.print "#{@thisLine}"
    else
      print "Found copyright line\n#{@thisLine}" if (@verbose.to_i > 2)
      print "1: #{x1} 2: #{x2} 3: #{x3} 4: #{x4} 5: #{x5} 6: #{x6} 7: #{x7}\n" if (@verbose.to_i > 2)
      @hasBanner = true
      scannedYear = x6
      correctYear = @Year
      if (@thisLine =~ /NeoLogic/)
        correctYear = 1997
      end
      if (scannedYear != correctYear)
        @changed = true
      end
      @output.print "#{x1}Copyright#{x2}#{x3}#{x4}#{x5}-#{correctYear}#{x7}\n"
      if (@multi_line_start.present? and @commentStart != @multi_line_start)
        print "#{@Line}: dodgy start of banner\n[#{@commentStart}]\n[#{@multi_line_start}]\n"; # if ( @verbose.to_i > 2 )
        @dodgyBanner = true
      end
    end
  elsif (changeable and !@pastHistory and @thisLine =~ /(.*)Copyright(.*)(\w+)(.*)([0-9][0-9]+)(.*)/)
    print "Found copyright2\n#{@thisLine}" if (@verbose.to_i > 2)
    x1, x2, x3, x4, x5, x6 = $1, $2, $3, $4, $5, $6
    if (!@incomment)
      print "Found copyright out of comment line\n#{@thisLine}"
      @output.print "#{@thisLine}"
    elsif (@thisLine =~ /Yahoo! Inc./)
      @OrigAuthor = "-"
      print "Not updating, #{@thisLine}"
      print "1: #{x1} 2: #{x2} 3: #{x3} 4: #{x4} 5: #{x5} 6: #{x6}\n" if (@verbose.to_i > 2)
      @hasBanner = true
      @output.print "#{@thisLine}"
    elsif (@OrigAuthor == "-")
      print "Found copyright but not updating\n#{@thisLine}"
      print "1: #{x1} 2: #{x2} 3: #{x3} 4: #{x4} 5: #{x5} 6: #{x6}\n" if (@verbose.to_i > 2)
      @hasBanner = true
      @output.print "#{@thisLine}"
    else
      print "Found copyright line\n#{@thisLine}" if (@verbose.to_i > 2)
      print "1: #{x1} 2: #{x2} 3: #{x3} 4: #{x4} 5: #{x5} 6: #{x6}\n" if (@verbose.to_i > 2)
      @hasBanner = true
      @scannedYear = x5
      @correctYear = @Year
      if (@thisLine =~ /NeoLogic/)
        @correctYear = 1997
      end
      if (@scannedYear != @correctYear)
        @changed = true
      end
      @output.print "#{x1}Copyright#{x2}#{x3}#{x4}#{x5}-#{@correctYear}#{x6}\n"
      if (@multi_line_start.present? and @commentStart != @multi_line_start)
        print "#{@Line}: dodgy start of banner\n[#{@commentStart}]\n[#{@multi_line_start}]\n"; # if ( @verbose.to_i > 2 )
        @dodgyBanner = true
      end
    end
  elsif (changeable and !@pastHistory and @thisLine =~ /Date.*Author.*/)
    # found start of history...
    print "Found start of history\n" if (@verbose.to_i > 2)
    @inHistory = true
    @hasHistory = true
    writeDAC
  elsif (changeable and !@pastHistory and @thisLine =~ /date.*author.*comment.*/)
    # found start of history...
    print "Found start of history (2)\n" if (@verbose.to_i > 2)
    @inHistory = true
    @hasHistory = true
    @changed = true
    writeDAC
  elsif (!@pastHistory and @thisLine =~ /-- Revision History/)
    print "Found 'Revision History' line\n#{@thisLine}" if (@verbose.to_i > 2)
    @inHistory = true
    @hasHistory = true
    @changed = true
    writeDAC
  elsif (!@pastHistory and @thisLine =~ @commentPattern)
    print "Found commentpattern\n#{@thisLine}" if (@verbose.to_i > 2)
    if (@inHistory)
      # already commented
      @hasComment = true
    end
    @output.print "#{@thisLine}"
  elsif (!@pastHistory and @thisLine =~ / File\s*:\s*([^\s]+)/)
    @file = $1
    print "Found File: #{@file}\n#{@thisLine}" if (@verbose.to_i > 2)
    if (@thisLine =~ /use File::/)
      @output.print "#{@thisLine}"
    elsif (@file == @File)
      @output.print "#{@thisLine}"
    elsif (@file == "#{@Parent}/#{@File}")
      @output.print "#{@thisLine}"
    elsif (@file =~ /^%.+%$/)
      @output.print "#{@thisLine}"
    elsif ((@file =~ /\// or @file =~ /\\/) and @file != "#{@Parent}/#{@File}")
      # but is it equal to directory/file?
      print "******* ERROR: #{@file} != #{@Parent}/#{@File}\n"
      @thisLine.sub!(@file, "#{@Parent}/#{@File}")
      @output.print @thisLine
      @changed = true
    elsif (@file != @File)
      # but is it equal to directory/file?
      print "******* ERROR: #{@file} != #{@File}\n"
      @thisLine.sub!(@file, @File)
      @output.print @thisLine
      @changed = true
    else
      @output.print "#{@thisLine}"
    end
  elsif (!@pastHistory and @thisLine =~ / Version\s*:\s*([^\s]+)/)
    @version = $1
    print "Found Version: @version\n#{@thisLine}" if (@verbose.to_i > 2)
    @MNPB = "@Major.@Minor.@Point.@Build"
    if (@version == @MNPB)
      @output.print "#{@thisLine}"
    elsif (@version != @MNPB)
      print "******* ERROR: @version != @MNPB\n"
      @thisLine.sub!(@version, @MNPB)
      @output.print @thisLine
      @changed = true
    else
      @output.print "#{@thisLine}"
    end
    #elsif ( !@pastHistory and /<\?xml/ && @fileType == "xml" )
    #  print "Found '<?xml..> line\n#{@thisLine}" if ( @verbose.to_i > 2 )
    #  #print "Found ?xml\n"
    #  @preBanner = @thisLine
  elsif (!@pastHistory and
      ((@fileType == "tmpl" and @thisLine =~ /^##var/) ||
       (@multi_line_end.present? and @thisLine =~ Regexp.new("#{Regexp.quote(@multi_line_end)}$")) ||
       (@single_line.present? and @thisLine =~ Regexp.new("^#{Regexp.quote(@single_line)}$")) ||
       (@single_line.present? and @thisLine =~ /^$/) ||
       (@single_line.present? and @thisLine !~ Regexp.new("^#{Regexp.quote(@single_line)}"))))
    if (@nComments < 2)
      print "found end of comments: #{@thisLine}" if (@verbose.to_i > 2)
    end
    @nComments += 1
    # end of comment?
    if (@inHistory && !@hasComment)
      print "were in history and hasComment is false\n#{@thisLine}" if (@verbose.to_i > 2)
      @changed = true
      writeLine
      @inHistory = false
      @pastHistory = true
      @commented = true
      #@hasComment = true
    elsif (@inHistory && @hasComment && !@commented)
      print "were in history and hasComment is true\n#{@thisLine}" if (@verbose.to_i > 2)
      @commented = true
      @pastHistory = true
    elsif (@inHistory)
      print "were in history and hasComment but @commented\n#{@thisLine}"; # if ( @verbose.to_i > 2 )
      #@commented = true
      #@pastHistory = true
    else
      print "were not in history\n#{@thisLine}" if (@verbose.to_i > 2)
      if (@single_line.present? and @nComments > 3)
        print "ERROR: no history\n#{@thisLine}"; # if ( @verbose.to_i > 2 )
        @pastHistory = true
      end
    end
    @output.print "#{@thisLine}"
  elsif (@fileType == "sql" and @thisLine =~ /updateConfig\s*\(\s*'(.+)',\s*'([.0-9]+)'\s*\)/i)
    # oracle call
    @shouldBe = "#{@Major}.#{@Minor}.#{@Point}.#{@Build}#{@Package}"
    @name = $1
    @num = $2

    @FileName = @File
    if (@FileName =~ /(.+)_s\.sql/)
      @FileName = $1
    elsif (@FileName =~ /(.+)_b\.sql/)
      @FileName = $1
    elsif (@FileName =~ /(.+)\.sql/)
      @FileName = $1
    end

    # No filename keys for updateConfig
    #schemaupgrade
    #incrementalupgrade
    #revisionnumber
    #databaseversion
    #baseschema
    #topclassusername
    @lcname = @name.downcase
    if (@lcname == "IncrementalUpgrade".downcase)
      @output.print "#{@thisLine}"
    else
      if (grep(/^@lcname$/, @nameExceptions))
      elsif (@lcname != @FileName.downcase)
        print "****** ERROR: UpdateConfig #{@name} != #{@FileName}\n"
      end
      if (grep(/^@lcname$/, @dataExceptions))
        @output.print "#{@thisLine}"
      elsif (@num != @shouldBe and @shouldBe != "...")
        print "call to updateConfig( '#{@name}', '#{@num}' )\n"
        print "shouldBe updateConfig( '#{@name}', '#{@shouldBe}' )\n"
        #@output.print "  updateConfig( '"#{@name}"', '"#{@shouldBe}"' );\n"
        @thisLine.sub!(@num, @shouldBe)
        @output.print @thisLine
        @changed = true
      else
        @output.print "#{@thisLine}"
      end
    end
  elsif @fileType == "sql" && @thisLine =~ /updateConfig\s*(N?)'(.+)',\s*(N?)'([.0-9]+)'\s*/i
    #EXECUTE updateConfig N'HELPER_VIEWS_PRE', N'7.3.0.008'
    # sql server call
    @shouldBe = "#{@Major}.#{@Minor}.#{@Point}.#{@Build}#{@Package}"
    @name = $2
    @num = $4
    @n1 = $1
    @n2 = $3

    @FileName = @File.sub(/(.+)\.sql/, '')

    @lcname = lc @name

    if (@lcname == "IncrementalUpgrade".downcase)
      @output.print @thisLine
    else
      if (grep(/^@lcname$/, @nameExceptions))
        #print "Found @lcname in \@nameExceptions\n"
      elsif (@lcname != @FileName.downcase)
        print "****** ERROR: UpdateConfig #{@name} != #{@FileName}\n"
      end
      if (grep(/^@lcname$/, @dataExceptions))
        #print "Found #{@lcname} in \#{@dataExceptions}\n"
        @output.print @thisLine
      elsif (@num != @shouldBe and @shouldBe != "...")
        print "call to updateConfig( #{@n1}'#{@name}', #{@n2}'#{@num}' )\n"
        print "shouldBe updateConfig( #{@n1}'#{@name}', #{@n2}'#{@shouldBe}' )\n"
        #@output.print "  EXECUTE updateConfig #{@n1}'#{@name}', #{@n2}'#{@shouldBe}';\n"
        @thisLine.sub!(@num, @shouldBe)
        @output.print @thisLine
        @changed = true
      else
        @output.print @thisLine
      end
    end
  else
    #print "lala\n"
    if (@inHistory and !@pastHistory)
      if (@thisLine =~ /\s+([0-9]+)(st|nd|rd|th)?\s+([A-Za-z]+)\s([0-9]+)\s+([a-zA-Z']+)\s+(.*)$/) #'
        @d, @th, @m, @y, @u, @c = $1, $2, $3, $4, $5, $6
        @c.sub!(/^(#\?{5}?) Lint/i, '#00007 Lint')
        @c.sub!(/^(#\?{4}?) Lint/i, '#0007 Lint')
        @c.sub!(/^Lint/i, '#0007 Lint')
        @c.sub!(/^(#\?+) MSVC 8/i, '#10544 MSVC 8')
        @c.sub!(/^(#\?+) CUpdater/i, '#9528 CUpdater')
        @c.sub!(/^(#\?+) [- :]+/i, '$1 ')
        @date = formatDate(@d, @m, @y)
        @newcomment = getCommentLine(@date, @u, @c)
        if (@thisLine != @newcomment)
          print "Old:#{@thisLine}" if (@verbose.to_i > 2)
          print "new:#{@newcomment}" if (@verbose.to_i > 2)
          @thisLine = @newcomment
        end
      elsif (@thisLine =~ /(\s{10,})(.+)$/)
        @c = $2
        @c.sub!(/^(#\?{5}?) Lint/i, '#00007 Lint')
        @c.sub!(/^(#\?{4}?) Lint/i, '#0007 Lint')
        @c.sub!(/^Lint/i, '#0007 Lint')
        @c.sub!(/^(#\?+) MSVC 8/i, '#10544 MSVC 8')
        @c.sub!(/^(#\?+) CUpdater/i, '#9528 CUpdater')
        @c.sub!(/^(#\?+) [- :]+/i, '$1 ')
        @newcomment = getCommentLine("", "", @c)
        if (@thisLine != @newcomment)
          print "Old:#{@thisLine}" if (@verbose.to_i > 2)
          print "new:#{@newcomment}" if (@verbose.to_i > 2)
          @thisLine = @newcomment
        end
      else
        print "Comment:#{@thisLine}"; # if ( @verbose.to_i > 2 )
      end
    end
    @output.print @thisLine
  end
end

@input.close
@output.close

print "changed: #{@changed} inHistory: #{@inHistory} pastHistory: #{@pastHistory} nComments: #{@nComments} hasComment: #{@hasComment} commented: #{@commented} hasBanner: #{@hasBanner} hasHistory: #{@hasHistory} dodgyBanner: #{@dodgyBanner}\n" if (@verbose.to_i > 2)

# had neither a banner nor a history
if (!@changed && !@hasBanner && !@hasHistory)
  puts "!@changed && !@hasBanner && !@hasHistory"
  @input = open(@infile) or die "can't open @infile\n"
  #print "Will try to open @outfile\n"
  @output = open(@outfile, 'w') or die "can't open @outfile\n"
  if (@FirstLine.present?)
    @output.print @FirstLine
  elsif (@bom)
    @output.print "\xef\xbb\xbf"
  end
  writeBanner
  writeHistory
  line_no = 0
  @input.each_line do |l|
    if (line_no == 0)
      l.gsub!(/\xef\xbb\xbf/, '')
    end
    if (@FirstLine.blank? or line_no > 0)
      @output.print l
    end
    line_no += 1
  end
  @input.close
  @output.close

# neither a history nor a banner but we updated something else?

elsif (@changed && !@hasBanner && !@hasHistory)
  puts "@changed && @hasBanner && !@hasHistory"
  File.rename @outfile, "#{@outfile}.tmp"
  @input = open("#{@outfile}.tmp") or die "can't open #{@outfile}.tmp\n"
  #print "Will try to open @outfile\n"
  @output = open(@outfile, 'w') or die "can't open #{@outfile}\n"
  if (@FirstLine.present?)
    @output.print @FirstLine
  elsif (@bom)
    @output.print "\xef\xbb\xbf"
  end
  writeBanner
  writeHistory
  line_no = 0
  @input.each_line do |l|
    if (line_no == 0)
      l.gsub!(/\xef\xbb\xbf/, '')
    end
    if (@FirstLine.blank? or line_no > 0)
      @output.print l
    end
    line_no += 1
  end
  @input.close
  @output.close
  File.unlink "#{@outfile}.tmp"

# had a history which we updated but no banner

elsif (@changed && !@hasBanner && @hasHistory)
  File.rename @outfile, "#{@outfile}.tmp"
  @input = open("#{@outfile}.tmp") or die "can't open #{@outfile}.tmp\n"
  #print "Will try to open @outfile\n"
  @output = open(@outfile, 'w') or die "can't open #{@outfile}\n"
  if (@FirstLine.present?)
    @output.print @FirstLine
  elsif (@bom)
    @output.print "\xef\xbb\xbf"
  end
  writeBanner
  line_no = 0
  @input.each_line do |l|
    if (line_no == 0)
      l.gsub!(/\xef\xbb\xbf/, '')
    end
    if (@FirstLine.blank? or line_no > 0)
      @output.print l
    end
    line_no += 1
  end
  @input.close
  @output.close
  File.unlink "#{@outfile}.tmp"

# had a banner but no history

elsif (@hasBanner && !@hasHistory)
  print "Found hasBanner && !hasHistory\n" if (@verbose.to_i > 2)
  File.rename @outfile, "#{@outfile}.tmp"
  @input = open("#{@outfile}.tmp", 'r') or die "can't open #{@outfile}.tmp\n"
  #print "Will try to open @outfile\n"
  @output = open(@outfile, 'w') or die "can't open #{@outfile}\n"
  #writeBanner
  comments = 0
  @writenHistory = false
  @input.each_line do |l|
    if ((@multi_line_end.present? and l =~ /^ *\Q@multi_line_end\E *$/) ||
        (@single_line.present? and l =~ /^ *\Q@single_line\E *$/))
      #print "end of comments\n"
      comments += 1
      # end of comment?
      @output.print l
      if (!@writenHistory)
        if (@single_line.blank? or comments == 2)
          writeHistory
          @writenHistory = true
        end
      end
    else
      @output.print l
    end
  end
  @input.close
  @output.close
  File.unlink "#{@outfile}.tmp"

# had a dodgy banner

elsif (@dodgyBanner)
  print "Fixing dodgy banner\n"; # if ( @verbose.to_i > 2 )
  @changed = true
  File.rename @outfile, "#{@outfile}.tmp"
  @input = open("#{@outfile}.tmp", 'r') or die "can't open #{@outfile}.tmp\n"
  #print "Will try to open @outfile\n"
  @output = open(@outfile, 'w') or die "can't open #{@outfile}\n"
  #writeBanner()
  @past = 0
  @input.each_line do |l|
    if (@past)
      @output.print l
    elsif (@multi_line_start.present? and l =~ /^\Q#{@multi_line_start}\E/)
      @output.print "#{@multi_line_start}\n"
      print "start of comments\n" if (@verbose.to_i > 2)
    elsif (@multi_line_end.present? and l =~ /\Q#{@multi_line_end}\E$/)
      @output.print "#{@multi_line_end}\n"
      @past = 1
      print "end of comments\n" if (@verbose.to_i > 2)
    else
      if (l =~ /^$ *$/)
        #@output.print "#{@multi_line_prefix} File: "#{$1}"\n"
      elsif (l =~ /^\Q@multi_line_end\E *File: (.+)/)
        @output.print "#{@multi_line_prefix} File: #{$1}\n"
      elsif (l =~ /^\Q@multi_line_end\E *Author: (.+)/)
        @output.print "#{@multi_line_prefix} Author: #{$1}\n"
      elsif (l =~ /^\Q@multi_line_end\E *Contents: (.+)/)
        @output.print "#{@multi_line_prefix} Contents: #{$1}\n"
      elsif (l =~ /^\Q@multi_line_end\E *Contents:/)
        @output.print "#{@multi_line_prefix} Contents:\n"
      elsif (l =~ /^\Q@multi_line_end\E *Copyright (.+), (.+)/)
        @output.print "#{@multi_line_prefix} Copyright #{$1}, #{$2}\n"
      elsif (l =~ /^\Q@multi_line_prefix\E( ?)(.+)/)
        @output.print "#{@multi_line_prefix} #{$2}\n"
      else
        @output.print l
      end
    end
  end
  @input.close
  @output.close
  File.unlink "#{@outfile}.tmp"
end

if (!@changed && @commented)
  print "No change\n" if (@verbose.to_i > 2)
  File.unlink @outfile
else
  print "Changed\n" if (@verbose.to_i > 2)
  if (@checkOut == "Y")
    CheckOut(@infile, @comments)
  end
  perm = File.stat(@infile).mode & 07777
  File.rename @infile, "#{@infile}.old"
  File.rename @outfile, @infile
  File.chmod(perm, @infile)
  perm = File.stat(@infile).mode & 07777
  if (@checkIn == "Y")
    CheckIn(@infile, @comments)
  end
end

if (@changeEvent == "Y")
  chevent(@infile, @comments)
end

#@line = "   22nd Feb 2008  eweb     #10850 Removed need for tcencrypt.jar\n"
#print @line
#@line = map_ids(@line)
#print @line


def runCmd(cmd)
  print "cmd: #{cmd}\n"
  open(CMD, "#{cmd} 2>&1 |").each_line do |line|
    print line
  end
end

def add_to_git_commit_msg(comment)
  gitmsg = "#{git_root}/.git/GITGUI_MSG"
  comments = open(gitmsg).lines
  chomp comments
  unless (grep(/\Q#{comment}\E/, comments))
    print "Adding #{comment} to commit message\n" if (@verbose.to_i > 2)
    comments << comment
    comments = sort comments
    open(gitmsg, 'w') do |cmt|
      comments.reverse.each do |c|
        cmt.puts c
      end
    end
  end
rescue => e
  print "Error: failed to open #{gitmsg} #{e}\n" if (@verbose.to_i > 2)
end

#<path-to-eclipse>\eclipse.exe -vm <path-to-vm>\java.exe -application org.eclipse.jdt.core.JavaCodeFormatter -verbose -config <path-to-config-file>\org.eclipse.jdt.core.prefs <path-to-your-source-files>\*.java

#/dev2/eclipse/eclipse -application org.eclipse.jdt.core.JavaCodeFormatter -verbose -config ~/projects/wacc/java/acc/.settings/org.eclipse.jdt.core.prefs <path-to-your-source-files>\*.java
