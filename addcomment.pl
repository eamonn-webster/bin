#!/usr/bin/env perl
#
# File: addcomment.pl
# Author: eweb
# Copyright WBT Systems, 2003-2011
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
#  6th Jul 2007  eweb     #00008 Determine version numbers from buildno.h
#  6th Jul 2007  eweb     #00008 handle addcomment.pl
# 12th Sep 2007  eweb     #00008 Was removing the call to updateConfig.
# 19th Sep 2007  eweb     #00008 Company and Start Year.
# 17th Jan 2008  eweb     #00008 Generic handling
# 17th Jan 2008  eweb     #00008 Need to quotemeta on pattern.
#  9th May 2008  eweb     #00008 template comments go before the vars
# 18th Jun 2008  eweb     #00008 Map fictional 80000 bug numbers.
# 18th Jul 2008  eweb     #00008 Lisa's username is too long.
# 24th Jul 2008  eweb     #00008 Restrict changes to history section
# 19th Sep 2008  eweb     #00008 handle html and css
# 24th Sep 2008  eweb     #00008 Roman's username
#  2nd Oct 2008  eweb     #00008 Preserve format of updateConfig
#  2nd Oct 2008  eweb     #00008 Not yet handling html
# 21st Nov 2008  eweb     #00008 Handle jsp(f), htm(l) and xml
#  1st Dec 2008  eweb     #00008 Map usernames
# 15th Jan 2009  eweb     #00008 Format of history
# 20th Jan 2009  eweb     #00008 Handle .def files, #???? Lint to #00007 Lint
# 21st Jan 2009  eweb     #00008 Formating history & Copyright
#  4th Mar 2009  eweb     #00008 End history with an empty comment
#  8th Apr 2009  eweb     #00008 Handle asps
# 16th Apr 2009  eweb     #00008 handle .rul files
# 28th May 2009  eweb     #00008 Respect number of question marks
#  2nd Nov 2009  eweb     #00008 Start year, .bas files
#  4th Dec 2009  eweb     #00008 Handle .properties, check banner
#  9th Dec 2009  eweb     #00008 xslt, fixing banner, detecting filename mismatches
# 17th Dec 2009  eweb     #00008 Checking File:addcomment.pl updateConfig, changed but no banner nor history
# 17th Dec 2009  eweb     #00008 fixing banner
# 14th Jan 2010  eweb     #00008 Handle .g, different message for directories
# 23rd Feb 2010  eweb     #00008 allow filename to be preceded by parent, .dtd files
# 18th Mar 2010  eweb     #00008 Don't change File: addcomment.pl it uses a variable
# 29th Mar 2010  eweb     #00008 Handle .jmx, don't add empty comments
# 20th May 2010  eweb     #00008 Avoid adding our copyright to yui files
# 20th May 2010  eweb     #00008 Had messed up copyright year
# 27th May 2010  eweb     #00008 Don't warn on IncrementalUpgrade mismatch
#  1st Jun 2010  eweb     #00008 Handle .vb files
# 23rd Jun 2010  eweb     #00008 Problems if banner but no history with single line comments
# 28th Jun 2010  eweb     #00008 Handle calls to updateConfig that only specify M.N.P
# 28th Jul 2010  eweb     #00008 Missing ]
#  8th Aug 2010  eweb     #00008 .idl files
# 19th Aug 2010  eweb     #00004 Known issue numbers
#  2nd Sep 2010  eweb     #00008 Handling use File::*
# 17th Sep 2010  eweb     #00008 Detect tabs and trailing spaces
# 29th Sep 2010  eweb     #00008 Handle .tld files
#  1st Nov 2010  eweb     #00008 Preserve bom
# 30th Nov 2010  eweb     #00008 Detect extended characters
# 30th Nov 2010  eweb     #00008 bhendrick is barry
#  9th Dec 2010  eweb     #00008 Call chevent, start year from version 0
# 17th Dec 2010  eweb     #00008 addcomment: chevent when not handled, -E to just chevent
#  6th Jan 2011  eweb     #00008 Ignore extended chars in foreign resource files
# 11th Jan 2011  eweb     #00008 Map usernames for original author
# 14th Jan 2011  eweb     #00008 perforce
#  3rd Feb 2011  eweb     #00008 Handle .xsd files
# 27th May 2011  eweb     #00008 UpdateConfig special cases
# 17th Jun 2011  eweb     #00008 Escape comment when searching
# 27th Jul 2011  eweb     #00008 check comments
#

# DONE change event if comment not present.
# TODO #00008 validate comments
# DONE html and xml need banner after doctype / xml declaration
# TODO #00008 execute permissions are lost (MacOS)
#
# Open the file.
# Scan header for copyright
# update year if necessary

# scan for history block
# append comment line to history

use strict;
use File::Spec;
use Getopt::Std;
use File::Basename;
use Cwd;
use File::Temp;

my $verbose;
my $VerifiedClearcase = "N";
my $UseClearcase = "Y";
my $cctool = "cleartool";
my $scc = "clearcase";
my $changeEvent = "Y";

my $preBanner;

my %bug_map = (
80001 => "00001",
80002 => "00002",
80003 => "00003",
80004 => "00004",
80005 => "00005",
80006 => "00006",
80007 => "00007",
80008 => "00008",
80009 => "00009",
80010 => 10735,
80011 => 10736,
80012 => 10737,
80013 => 10738,
80014 => 10739,
80015 => 10740,
80016 => 10741,
80017 => 10742,
80018 => 10743,
80019 => 10744,
80020 => 10745,
80021 => 10746,
80022 => 10747,
80023 => 10748,
80024 => 10749,
80025 => 10750,
80026 => 10751,
80027 => 10752,
80028 => 10753,
80029 => 10754,
80030 => 10755,
80031 => 10756,
80032 => 10757,
80033 => 10758,
80034 => 10759,
80035 => 10760,
80036 => 10761,
80037 => 10762,
80038 => 10763,
80039 => 10764,
80040 => 10765,
80041 => 10766,
80042 => 10767,
80043 => 10768,
80044 => 10769,
80045 => 10770,
80046 => 10771,
80047 => 10772,
80048 => 10773,
80049 => 10774,
80050 => 10775,
80051 => 10776,
80052 => 10777,
80053 => 10778,
80054 => 10779,
80055 => 10780,
80056 => 10781,
80057 => 10782,
80058 => 10783,
80059 => 10784,
80060 => 10785,
80061 => 10786,
80062 => 10787,
80063 => 10788,
80063 => 10789,
80064 => 10790,
80065 => 10791,
80066 => 10792,
80067 => 10793,
80068 => 10794,
80069 => 10795,
80070 => 10796,
80071 => 10797,
80072 => 10798,
80073 => 10799,
80074 => 10800,
80075 => 10801,
80076 => 10802,
80077 => 10803,
80078 => 10804,
80079 => 10805,
80080 => 10806,
80081 => 10807,
80082 => 10808,
80083 => 10809,
80084 => 10810,
80085 => 10811,
80086 => 10812,
80087 => 10813,
80088 => 10814,
80089 => 10815,
80090 => 10816,
80091 => 10817,
80092 => 10818,
80093 => 10819,
80094 => 10820,
80095 => 10821,
80095 => 10822,
80097 => 10823,
80098 => 10824,
80099 => 10825,
80100 => 10826,
80101 => 10827,
80102 => 10828,
80103 => 10829,
80104 => 10830,
80105 => 10831,
80106 => 10832,
80108 => 10833,
80109 => 10834,
80110 => 10835,
80111 => 10836,
80112 => 10837,
80113 => 10838,
80114 => 10839,
80115 => 10840,
80116 => 10841,
80117 => 10842,
80118 => 10843,
80119 => 10844,
80120 => 10845,
80121 => 10846,
80122 => 10847,
80123 => 10848,
80124 => 10849,
80125 => 10850,
80126 => 10851,
80127 => 10852,
80128 => 10853,
80129 => 10854,
80130 => 10855,
80131 => 10856,
80132 => 10857,
80133 => 10858,
80134 => 10859,
80135 => 10860,
80136 => 10861,
80137 => 10862,
80138 => 10863,
80139 => 10864,
80140 => 10865,
80141 => 10866,
80142 => 10867,
80143 => 10868,
80144 => 10869,
80145 => 10870,
80146 => 10871,
80147 => 10872,
80148 => 10873,
80149 => 10874,
80150 => 10875,
80151 => 10876,
80152 => 10877,
80153 => 10878,
80154 => 10879,
80155 => 10880,
80156 => 10881,
80157 => 10882,
80158 => 10883,
80159 => 10884,
80160 => 10885,
80161 => 10886,
80162 => 10887,
80163 => 10888,
80164 => 10889,
80165 => 10890,
80166 => 10891,
80167 => 10892,
80168 => 10893,
80169 => 10894,
80170 => 10895,
80171 => 10896,
80172 => 10897,
80173 => 10898,
80174 => 10899,
80175 => 10900,
80176 => 10901,
80177 => 10902,
80178 => 10903,
80179 => 10904,
80180 => 10905,
80181 => 10906,
80182 => 10907,
80183 => 10908,
80184 => 10909,
80185 => 10910,
80186 => 10911,
80187 => 10912,
80188 => 10913,
80189 => 10914,
80190 => 10915,
80191 => 10916,
80192 => 10917,
80193 => 10918,
80194 => 10919,
80195 => 10920,
80196 => 10921,
80197 => 10922,
80198 => 10923,
80199 => 10924,
80200 => 10925,
80201 => 10926,
80202 => 10927,
80203 => 10928,
80204 => 10929,
80205 => 10930,
80206 => 10931,
80207 => 10932,
80208 => 10933,
80209 => 10934,
80210 => 10935,
80211 => 10936,
80212 => 10937,
80213 => 10938,
80214 => 10939,
80215 => 10940,
80216 => 10941,
80217 => 10942,
80218 => 10943,
80219 => 10944,
80220 => 10945,
);

my @nameExceptions = qw/schemaupgrade incrementalupgrade revisionnumber databaseversion baseschema topclassusername/;
my @dataExceptions = qw/incrementalupgrade revisionnumber databaseversion topclassusername/;

my %opts = ( a => undef(),
             c => undef(),
             E => undef(),
             A => undef(),
             C => undef(),
             i => undef(),
             o => undef(),
             m => undef(),
             n => undef(),
             p => undef(),
             b => undef(),
             k => undef(),
             S => undef(),
             v => undef(),
             x => undef(),
           );

# Was anything other than the defined option entered on the command line?
if ( !getopts("c:a:A:C:Eiom:n:p:b:k:S:v:x:", \%opts) or @ARGV > 1 ) {
    print STDERR "Unknown arg $ARGV[0]\n" if @ARGV > 0;
    #Usage();
    exit;
}


my $scc = "clearcase";

  if ( -d ".git" ) {
    $scc = "git";
  }
  else {
    my $cwd = getcwd();
    if ( $cwd =~ /p4clients/ ) {
      $scc = "p4";
    }
  }

sub verifyClearcase() {
    if ( $VerifiedClearcase eq "N" and $UseClearcase eq "Y" ) {
        $cctool = "cleartool";
        my $desc = `$cctool desc -fmt \"[%m]\" "\\topclass"`;
        if ( $desc eq "[**null meta type**]" ) {
            print "Not a clearcase drive\n";
            $cctool = "";
            $UseClearcase = "N";
        }
        elsif ( $desc eq "[directory version]" ) {
            print "Is a clearcase drive\n";
            $UseClearcase = "Y";
        }
        elsif ( $desc eq "" ) {
            print "Looks like we don't have cleartool\n";
            $cctool = "";
            $UseClearcase = "N";
        }
        $VerifiedClearcase = "Y";
    }
}

sub CheckIn($$) {
    my ($file, $comment) = @_;

    my $cmd = "$cctool ci -c \"$comment\" $file";
    print "$cmd\n";
    my $results = `$cmd 2>&1`;

    if ( $results =~ /Error: By default, won\'t create version with data identical to predecessor./ ) {
        # hasn't changed so undo the check out.
        $cmd = "$cctool unco -rm $file";
        $results = $results . "\n" . $cmd . "\n" . `$cmd 2>&1`;
    }
    elsif ( $results =~ /Error: Not an element:/ ) {
        # Not an element
    }
    elsif ( $results =~ /Error:/ ) {
        # Not an element
    }
    else {
        # Not an element
    }
    print "$results\n";
}

sub CheckOut($$) {
    my ($file, $comment) = @_;

    my $cmd = "$cctool co -c \"$comment\" $file";

    print "$cmd\n";

    my $results = `$cmd 2>&1`;

    if ( $results =~ /Error: Element "(.+)" is already checked out to view "(.+)"/ ) {
    }
    elsif ( $results =~ /Error: Not a vob object:/ ) {
        # Not an element
    }
    elsif ( $results =~ /Error: / ) {
    }

    print "$results\n";
}

my $Year;

sub FormatToday() {
  my ($Sec, $Min, $Hour, $Day, $Mon, $y ) = localtime(time);

  $Year  = $y + 1900;

  my @Months = ( "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" );

  my $Month = @Months[$Mon];

  return formatDate($Day, $Month, $Year);
}

my $Date = FormatToday();

sub formatDate($$$) {
  my ($d, $m, $y) = @_;

  #my $Month = @Months[$Mon];
  #$Mon = $Mon + 1;

  my $Th = "th";
  $d++;
  $d--;
  if ( $d == 1 || $d == 21 || $d == 31 ) {
    $Th = "st";
  }
  elsif ( $d == 2 || $d == 22 ) {
    $Th = "nd";
  }
  elsif ( $d == 3 || $d == 23 ) {
    $Th = "rd";
  }
  if ( $d < 10 ) {
    $d = " $d";
  }

  return "$d$Th $m $y";
}

my $infile;
my $Comments;
my $Author;
my $OrigAuthor;
my $Company;
my $CompanyX;
my $checkIn;
my $checkOut;
my $Major;
my $Minor;
my $Point;
my $Build;
my $Package;
my $StartYear;
my $MultiLineStart;
my $MultiLineEnd;
my $MultiLinePrefix;
my $SingleLine;
my $VeryFirstLine;
my $FirstLine;
my $bom;
my $JustChangeEvent;
my $ValidateComments = 1;

$infile = $ARGV[0];

if ( defined( $opts{c} ) ) {
    $Comments = $opts{c};
}

if ( defined( $opts{a} ) ) {
    $Author = $opts{a};
}

if ( defined( $opts{A} ) ) {
    $OrigAuthor = $opts{A};
}

if ( defined( $opts{E} ) ) {
    $JustChangeEvent = 1;
}

if ( defined( $opts{C} ) ) {
    $Company = $opts{C};
    $CompanyX = $opts{C};
}

if ( defined( $opts{i} ) ) {
    $checkIn = "Y";
}

if ( defined( $opts{x} ) ) {
    $changeEvent = uc $opts{x};
}

$verbose = $opts{v};

if ( defined( $opts{o} ) ) {
    $checkOut = "Y";
}

if ( defined( $opts{m} ) ) {
    $Major = $opts{m};
}
if ( defined( $opts{n} ) ) {
    $Minor = $opts{n};
}
if ( defined( $opts{p} ) ) {
    $Point = $opts{p};
}
if ( defined( $opts{b} ) ) {
    $Build = $opts{b};
}
if ( defined( $opts{k} ) ) {
    $Package = $opts{k};
}
if ( defined( $opts{S} ) ) {
    $StartYear = $opts{S};
}

my $abs_path = File::Spec->rel2abs( $infile ) ;
my $drive;
if ( $abs_path =~ /^(.:)/ ) {
    $drive = $1;
}

my $outfile = "$infile.new";

my %usernameMap = (
 lmcgettigan => "lisa",
 rgeraschenko => "rger",
 aemelyanov => "deesy",
 bhendrick => "barry",
);

if ( $Author eq "" ) {
    $Author = lc $ENV{USERNAME};
    $Author = lc $ENV{USER} if ( $^O eq "darwin" );
    if ( $usernameMap{$Author} ne "" ) {
        $Author = $usernameMap{$Author};
    }
}
if ( $OrigAuthor eq "" and $scc eq "clearcase" ) {
    $OrigAuthor = `cleartool desc -fmt "%u" $infile\@\@\\main\\0`;
    if ( $usernameMap{$OrigAuthor} ne "" ) {
        $OrigAuthor = $usernameMap{$OrigAuthor};
    }
}
if ( $OrigAuthor eq "" ) {
    $OrigAuthor = $Author;
}
elsif ( $OrigAuthor eq "." ) {
    $OrigAuthor = "";
}

if ( $Company eq "" ) {
    $Company = "WBT Systems";
}
if ( $StartYear eq "" and $scc eq "clearcase" ) {
    my $date = `cleartool desc -fmt "%Nd" $infile\@\@\\main\\0`;
    if ( $date =~ /(^[0-9]{4})/ ) {
      $StartYear = $1;
    }
}
if ( $StartYear eq "" ) {
    if ( $Company eq "WBT Systems" ) {
        $StartYear = "1995";
    }
    else {
        $StartYear = $Year;
    }
}

if ( $infile =~ m!(/|\\)yui\1! ) {
  #print "Part of yui\n";
  #$OrigAuthor = "-";
}

# determine filename and immediate parent
my ($File, $path) = fileparse($infile);

#print "($File, $path)\n";

# strip trailing slash
$path =~ s!/$!!;
$path =~ s!\\$!!;

#print "($File, $path)\n";

my ($Parent) = fileparse($path);

my $fileType = "";

$Comments =~ s/^\s+//;
$Comments =~ s/\s+$//;

if ( $ValidateComments ) {
    if ( $Comments =~ /^\#[0-9]{4,5} .+/ ||
         $Comments =~ /^\#[A-Z]+-[0-9]{3,5} .+/ ) {
      $Comments = join( ' ', split( / +/, $Comments ) );
    }
    elsif ( $Comments eq "" ) {
       print "Empty comment\n";
    }
    elsif ( $Comments =~ /^\#\?+/ ) {
       die "ERROR: Invalid comment\n";
    }
    else {
       die "ERROR: Invalid comment\n";
    }
}

    if ( $JustChangeEvent ) {
        chevent($infile, $Comments );
        exit;
    }
    elsif ( $File =~ /\.dsw$/ or
            $File =~ /\.dsp$/ or
            $File =~ /\.dat$/ ) {
        print "Unhandled file type $File\n";
        if ( $changeEvent eq "Y" ) {
          chevent($infile, $Comments );
        }
        exit;
    }
    elsif ( $File =~ /\.cpp$/ or
            $File =~ /\.h$/ or
            $File =~ /\.rh$/ or
            $File =~ /\.inc$/ or
            $File =~ /\.js$/ or
            $File =~ /\.c$/ or
            $File =~ /\.rc$/ or
            $File =~ /\.rc2$/ or
            $File =~ /\.lnt$/ or
            $File =~ /\.css$/ or
            $File =~ /\.rul$/ or
            $File =~ /\.g$/ or
            $File =~ /\.java$/ or
            $File =~ /\.idl$/ ) {
        $fileType = "c++";
        $MultiLineStart = "/*";
        $MultiLineEnd = "*/";
        $MultiLinePrefix = "  ";
    }
    elsif ( $File =~ /\.xml$/ or $File =~ /\.xslt$/ or $File =~ /\.dtd$/ or $File =~ /\.jmx$/ or $File =~ /\.tld$/ or $File =~ /\.xsd$/ ) {
        $fileType = "xml";
        $MultiLineStart = "<!--";
        $MultiLineEnd = "-->";
        $MultiLinePrefix = "  ";
        $VeryFirstLine = "<?xml.*>";
        #die "Unhandled file type $File\n";
    }
    elsif ( $File =~ /\.sql$/ ) {
        $fileType = "sql";
        $SingleLine = "--";
        #die "Unhandled file type $File\n";
    }
    elsif ( $File =~ /\.rb$/ or
            $File =~ /\.pl$/ or
            $File =~ /\.properties$/ ) {
        $fileType = "pl";
        $SingleLine = "#";
        #die "Unhandled file type $File\n";
    }
    elsif ( $File =~ /\.tmpl$/ ) {
        $fileType = "tmpl";
        $SingleLine = "#";
        #die "Unhandled file type $File\n";
    }
    elsif ( $File =~ /\.lsp$/ ) {
        $fileType = "lsp";
        $MultiLineStart = "#|";
        $MultiLineEnd = "|#";
        $MultiLinePrefix = "  ";
        #$SingleLine = ";";
        #die "Unhandled file type $File\n";
    }
    elsif ( $File =~ /\.bat$/ or $File =~ /\.cmd$/ ) {
        $fileType = "bat";
        $SingleLine = "::";
        #die "Unhandled file type $File\n";
    }
    elsif ( $File =~ /\.def$/ or $File =~ /\.cmd$/ ) {
        $fileType = "def";
        $SingleLine = ";";
        #die "Unhandled file type $File\n";
    }
    elsif ( $File =~ /\.jsp$/ or $File =~ /\.jspf$/ ) {
        $fileType = "jsp";
        $MultiLineStart = "<%/*";
        $MultiLineEnd = "*/%>";
        $MultiLinePrefix = "  ";
        #die "Unhandled file type $File\n";
    }
    elsif ( $File =~ /\.html$/ or $File =~ /\.htm$/ ) {
        $fileType = "html";
        $MultiLineStart = "<!--";
        $MultiLineEnd = "-->";
        $MultiLinePrefix = "  ";
        $VeryFirstLine = "<!DOCTYPE.*>";
        #die "Unhandled file type $File\n";
    }
    elsif ( $File =~ /\.asp$/ ) {
        $fileType = "asp";
        $MultiLineStart = "<%";
        $MultiLineEnd = "%>";
        $MultiLinePrefix = "' ";
        #die "Unhandled file type $File\n";
    }
    elsif ( $File =~ /\.bas$/ or $File =~ /\.vb$/ ) {
        $fileType = "bas";
        $SingleLine = "'";
        #die "Unhandled file type $File\n";
    }
    elsif ( -d $infile ) {
        print "Don't comment directories\n";
        if ( $changeEvent eq "Y" ) {
          chevent($infile, $Comments );
        }
        exit;
    }
    else {
        print "Unhandled file type $File\n";
        if ( $changeEvent eq "Y" ) {
          chevent($infile, $Comments );
        }
        exit;
    }

#print "Will try to open $infile\n";
open (INPUT,$infile) or die "can't open $infile\n";
#print "Will try to open $outfile\n";
open (OUTPUT,">$outfile") or die "can't open $outfile\n";

my $changed = 0;
my $inHistory = 0;
my $pastHistory = 0;
my $nComments = 0;
my $hasComment = 0;
my $commented = 0;
my $hasBanner = 0;
my $hasHistory = 0;

my $commentPattern = quotemeta($Date) . " +" . quotemeta($Author) . " +" . quotemeta($Comments); # [addcomment.pl don't change]

print "\$commentPattern [$commentPattern]\n" if ( $verbose );

sub writeHistory() {
  if ( $MultiLineStart ne "" ) {
    print OUTPUT "$MultiLineStart\n";
  }
  writeDAC();
  writeLine();
  if ( $MultiLineStart ne "" ) {
    print OUTPUT "$MultiLineEnd\n";
  }
  else {
    print OUTPUT "$SingleLine\n";
  }
  $changed = 1;
}

sub writeBanner() {
  if ( $OrigAuthor eq "-" ) {
  }
  else {
    if ( $MultiLineStart ne "" ) {
      print OUTPUT "$MultiLineStart\n";
      print OUTPUT "$MultiLinePrefix File: $File\n";
      print OUTPUT "$MultiLinePrefix Author: $OrigAuthor\n";
      print OUTPUT "$MultiLinePrefix Copyright $Company, $StartYear-$Year\n";
      print OUTPUT "$MultiLinePrefix Contents:\n";
      print OUTPUT "$MultiLineEnd\n";
    }
    else {
      print OUTPUT "$SingleLine\n";
      print OUTPUT "$SingleLine File: $File\n";
      print OUTPUT "$SingleLine Author: $OrigAuthor\n";
      print OUTPUT "$SingleLine Copyright $Company, $StartYear-$Year\n";
      print OUTPUT "$SingleLine Contents:\n";
      print OUTPUT "$SingleLine\n";
    }
  }
}

sub getCommentLine($$$) {
  my ($Date, $Author, $Comments) = @_; # [addcomment.pl don't change]
  if ( $Comments eq "" ) {
    if ( $MultiLineStart ne "" ) {
      return sprintf "$MultiLinePrefix %-14s %s\n", $Date, $Author; # [addcomment.pl don't change]
    }
    else {
      return sprintf "$SingleLine %-14s %s\n", $Date, $Author; # [addcomment.pl don't change]
    }
  }
  else {
    if ( $MultiLineStart ne "" ) {
      return sprintf "$MultiLinePrefix %-14s %-8s %s\n", $Date, $Author, $Comments; # [addcomment.pl don't change]
    }
    else {
      return sprintf "$SingleLine %-14s %-8s %s\n", $Date, $Author, $Comments; # [addcomment.pl don't change]
    }
  }
}
sub writeDAC() {
  print OUTPUT getCommentLine("Date:", "Author:", "Comments:" ); # [addcomment.pl don't change]
}
sub writeLine() {
  # don't add empty comment.
  if ( $Comments ne "" ) {
    print OUTPUT getCommentLine($Date, $Author, $Comments); # [addcomment.pl don't change]
  }
}

GetBuildNumber( $drive );


#print OUTPUT "Stuff and bother\n";
#print "Stuff and bother\n";
#while ( $_ = <INPUT> )
my $dodgyBanner;
my $pastBanner;
my $commentStart;
my $commentEnd;
my $Line = 0;
my $incomment;
my $trailingSpace;
my $tabs;

while ( <INPUT> ) {
    my $thisLine = $_;

    if ( $Line == 0 and $thisLine =~ /\x{ef}\x{bb}\x{bf}/ ) {
      $bom = 1;
    }

    if ( $Line == 0 and $VeryFirstLine ne "" && /$VeryFirstLine/ ) {
       $FirstLine = $thisLine;
    }

    $Line++;

    if ( $thisLine =~ /\t/ ) {
        print STDERR "TABS!!! Tabs found at line $Line\n";
    }
    if ( $thisLine =~ /[ \t][\r\n]/ ) {
        print STDERR "SPACE!!! Trailing space found at line $Line\n";
    }
    if ( $thisLine =~ /[^\x20-\x7f\t\n\r]/ ) {
        if ( $infile =~ /resources_..\.properties/ ) {
        }
        elsif ( $infile =~ /_.+\.dat/ and $infile !~ /english/ ) {
        }
        else {
            print STDERR "DODGY!!! extended character found at line $Line\n";
        }
    }
    my $bugchanged = 0;
    my $found80000 = 0;
    my $newline = map_ids( $thisLine, \$bugchanged, \$found80000 );
    if ( $bugchanged ) {
        #print "mapped bug_id\n";
        $thisLine = $newline;
        $changed = 1;
    }
    if ( $thisLine =~ /#8[0-9?]{4}/ && !/\[addcomment\.pl don\'t change\]/ ) {  # [addcomment.pl don't change]
        print STDERR "$thisLine\n";
    }
    $_ = $thisLine;
    if ( $MultiLineStart ne "" && /\Q$MultiLineStart\E/ ) {
      #print "Found start of multiline\n$_" if ( $verbose );
      $incomment = 1;
      $commentStart = $_;
      chomp($commentStart);
    }
    elsif ( $MultiLineEnd ne "" && /\Q$MultiLineEnd\E/ ) {
      #print "Found end of multiline\n$_" if ( $verbose );
      $incomment = undef;
      $commentEnd = $_;
      chomp($commentEnd);

      if ( $hasBanner and !$pastBanner ) {
        $pastBanner = 1;
        if ( $commentEnd ne $MultiLineEnd ) {
          print "$Line: dodgy end of banner\n[$commentEnd]\n[$MultiLineEnd]\n";# if ( $verbose );
          $dodgyBanner = 1;
        }
      }
    }
    elsif ( $SingleLine ne "" and /^\Q$SingleLine\E/ ) {
      $incomment = 1;
    }
    elsif ( $SingleLine ne "" ) {
      $incomment = undef;
    }

    if ( !$pastHistory and /(.*)Copyright(.*)(\w+)(.*)([0-9][0-9]+)-([0-9][0-9]+)(.*)/ && !/\[addcomment\.pl don\'t change\]/ ) { # [addcomment.pl don't change]
        print "Found copyright1\n$_" if ( $verbose );
        if ( !$incomment ) {
            print "Found copyright out of comment line\n$_";
            print OUTPUT "$_";
        }
        elsif ( /Yahoo! Inc./ ) {
            print "Found Yahoo copyright\n$_" if ( $verbose );
            $OrigAuthor = "-";
            print "Not updating, $_";
            print "1: $1 2: $2 3: $3 4: $4 5: $5 6: $6 7: $7\n" if ( $verbose );
            $hasBanner = 1;
            print OUTPUT "$_";
        }
        elsif ( $OrigAuthor eq "-" ) {
            print "Found copyright but OrigAuthor is -\n$_" if ( $verbose );
            print "Found copyright but not updating\n$_";
            print "1: $1 2: $2 3: $3 4: $4 5: $5 6: $6 7: $7\n" if ( $verbose );
            $hasBanner = 1;
            print OUTPUT "$_";
        }
        else {
            print "Found copyright line\n$_" if ( $verbose );
            print "1: $1 2: $2 3: $3 4: $4 5: $5 6: $6 7: $7\n" if ( $verbose );
            $hasBanner = 1;
            my $scannedYear = $6;
            my $correctYear = $Year;
            if ( /NeoLogic/ ) {
              $correctYear = 1997;
            }
            if ( $scannedYear ne $correctYear ) {
              $changed = 1;
            }
            print OUTPUT "$1Copyright$2$3$4$5-$correctYear$7\n";
            if ( $MultiLineStart ne "" and $commentStart ne $MultiLineStart ) {
              print "$Line: dodgy start of banner\n[$commentStart]\n[$MultiLineStart]\n";# if ( $verbose );
              $dodgyBanner = 1;
            }
        }
    }
    elsif ( !$pastHistory and /(.*)Copyright(.*)(\w+)(.*)([0-9][0-9]+)(.*)/ && !/\[addcomment\.pl don\'t change\]/ ) { # [addcomment.pl don't change]
        print "Found copyright2\n$_" if ( $verbose );
        if ( !$incomment ) {
            print "Found copyright out of comment line\n$_";
            print OUTPUT "$_";
        }
        elsif ( /Yahoo! Inc./ ) {
            $OrigAuthor = "-";
            print "Not updating, $_";
            #print "1: $1 2: $2 3: $3 4: $4 5: $5 6: $6\n";
            $hasBanner = 1;
            print OUTPUT "$_";
        }
        elsif ( $OrigAuthor eq "-" ) {
            print "Found copyright but not updating\n$_";
            print "1: $1 2: $2 3: $3 4: $4 5: $5 6: $6\n" if ( $verbose );
            $hasBanner = 1;
            print OUTPUT "$_";
        }
        else {
            print "Found copyright line\n$_" if ( $verbose );
            print "1: $1 2: $2 3: $3 4: $4 5: $5 6: $6\n" if ( $verbose );
            $hasBanner = 1;
            my $scannedYear = $5;
            my $correctYear = $Year;
            if ( /NeoLogic/ ) {
              $correctYear = 1997;
            }
            if ( $scannedYear ne $correctYear ) {
              $changed = 1;
            }
            print OUTPUT "$1Copyright$2$3$4$5-$correctYear$6\n";
            if ( $MultiLineStart ne "" and $commentStart ne $MultiLineStart ) {
              print "$Line: dodgy start of banner\n[$commentStart]\n[$MultiLineStart]\n";# if ( $verbose );
              $dodgyBanner = 1;
            }
        }
    }
    elsif ( !$pastHistory and /Date.*Author.*/ && !/\[addcomment\.pl don\'t change\]/ ) { # [addcomment.pl don't change]
        # found start of history...
        #print "Found start of history\n";
        $inHistory = 1;
        $hasHistory = 1;
        writeDAC();
    }
    elsif ( !$pastHistory and /date.*author.*comment.*/ and !/\[addcomment\.pl don\'t change\]/ ) { # [addcomment.pl don't change]
        # found start of history...
        #print "Found start of history (2)\n";
        $inHistory = 1;
        $hasHistory = 1;
        $changed = 1;
        writeDAC();
    }
    elsif ( !$pastHistory and /-- Revision History/ and !/\[addcomment\.pl don\'t change\]/ ) { # [addcomment.pl don't change]
        print "Found 'Revision History' line\n$_" if ( $verbose );
        $inHistory = 1;
        $hasHistory = 1;
        $changed = 1;
        writeDAC();
    }
    elsif ( !$pastHistory and /$commentPattern/ ) {
        print "Found commentpattern\n$_" if ( $verbose );
        if ( $inHistory == 1 ) {
            # already commented
            $hasComment = 1;
        }
        print OUTPUT "$_";
    }
    elsif ( !$pastHistory and / File\s*:\s*([^\s]+)/ and !/\[addcomment\.pl don\'t change\]/ ) {# [addcomment.pl don't change] '
        my $file = $1;
        print "Found File: $file\n$_" if ( $verbose );
        if ( /use File::/ ) {
          print OUTPUT "$_";
        }
        elsif ( $file eq $File ) {
          print OUTPUT "$_";
        }
        elsif ( $file eq "$Parent/$File" ) {
          print OUTPUT "$_";
        }
        elsif ( $file =~ /^%.+%$/ ) {
          print OUTPUT "$_";
        }
        elsif ( ($file =~ /\// or $file =~ /\\/ ) and $file ne "$Parent/$File" ) {
          # but is it equal to directory/file?
          print "******* ERROR: $file ne $Parent/$File\n";
          $thisLine =~ s!\Q$file\E!$Parent/$File!;
          print OUTPUT $thisLine;
          $changed = 1;
        }
        elsif ( $file ne $File ) {
          # but is it equal to directory/file?
          print "******* ERROR: $file ne $File\n";
          $thisLine =~ s/$file/$File/;
          print OUTPUT $thisLine;
          $changed = 1;
        }
        else {
          print OUTPUT "$_";
        }
    }
#    elsif ( !$pastHistory and /<\?xml/ && $fileType eq "xml" ) {
#        print "Found '<?xml..> line\n$_" if ( $verbose );
#        #print "Found ?xml\n";
#        $preBanner = $_;
#    }
    elsif ( !$pastHistory and
            ( ( $fileType eq "tmpl" and /^##var/ ) ||
              ( $MultiLineEnd ne "" and /\Q$MultiLineEnd\E/ ) ||
              ( $SingleLine ne "" and /^\Q$SingleLine\E$/ ) ||
              ( $SingleLine ne "" and /^$/ ) ||
              ( $SingleLine ne "" and ! /^\Q$SingleLine\E/ ) ) ) {
        if ( $nComments < 2 ) {
            print "found end of comments: $_" if ( $verbose );
        }
        $nComments++;
        # end of comment?
        if ( $inHistory == 1 && $hasComment == 0 ) {
            print "were in history and hasComment is false\n$_" if ( $verbose );
            $changed = 1;
            writeLine();
            $inHistory = 0;
            $pastHistory = 1;
            $commented = 1;
            #$hasComment = 1;
        }
        elsif ( $inHistory == 1 && $hasComment == 1 && $commented ne 1 ) {
            print "were in history and hasComment is true\n$_" if ( $verbose );
            $commented = 1;
            $pastHistory = 1;
        }
        elsif ( $inHistory == 1 ) {
            print "were in history and hasComment but $commented\n$_"; # if ( $verbose );
            #$commented = 1;
            #$pastHistory = 1;
        }
        else {
            print "were not in history\n$_" if ( $verbose );
            if ( $SingleLine ne "" and $nComments > 3 ) {
              print "ERROR: no history\n$_"; # if ( $verbose );
              $pastHistory = 1;
            }
        }
        print OUTPUT "$_";
    }
    elsif ( $fileType eq "sql" && /updateConfig\s*\(\s*'(.+)',\s*'([.0-9]+)'\s*\)/i ) {
        # oracle call
        my $shouldBe = "$Major.$Minor.$Point.$Build$Package";
        my $name = $1;
        my $num = $2;

        my $FileName = $File;
        if ( $FileName =~ /(.+)_s\.sql/ ) {
            $FileName = $1;
        }
        elsif ( $FileName =~ /(.+)_b\.sql/ ) {
            $FileName = $1;
        }
        elsif ( $FileName =~ /(.+)\.sql/ ) {
            $FileName = $1;
        }

        # No filename keys for updateConfig
        #schemaupgrade
        #incrementalupgrade
        #revisionnumber
        #databaseversion
        #baseschema
        #topclassusername
        my $lcname = lc $name;
        if ( $lcname eq lc "IncrementalUpgrade" ) {
            print OUTPUT "$_";
        }
        else {
            if ( grep( /^$lcname$/, @nameExceptions ) ) {
            }
            elsif ( $lcname ne lc $FileName ) {
                print "****** ERROR: UpdateConfig $name ne $FileName\n";
            }
            if ( grep( /^$lcname$/, @dataExceptions ) ) {
                print OUTPUT "$_";
            }
            elsif ( $num ne $shouldBe and $shouldBe ne "..." ) {
                print "call to updateConfig( '$name', '$num' )\n";
                print "shouldBe updateConfig( '$name', '$shouldBe' )\n";
                #print OUTPUT "  updateConfig( '$name', '$shouldBe' );\n";
                $thisLine =~ s/$num/$shouldBe/;
                print OUTPUT $thisLine;
                $changed = 1;
            }
            else {
                print OUTPUT "$_";
            }
        }
    }
    elsif ( $fileType eq "sql" && /updateConfig\s*(N?)'(.+)',\s*(N?)'([.0-9]+)'\s*/i ) {
        #EXECUTE updateConfig N'HELPER_VIEWS_PRE', N'7.3.0.008';
        # sql server call
        my $shouldBe = "$Major.$Minor.$Point.$Build$Package";
        my $name = $2;
        my $num = $4;
        my $n1 = $1;
        my $n2 = $3;

        my ($FileName) = $File =~ /(.+)\.sql/;

        my $lcname = lc $name;

        if ( $lcname eq lc "IncrementalUpgrade" ) {
            print OUTPUT "$_";
        }
        else {
            if ( grep( /^$lcname$/, @nameExceptions ) ) {
                #print "Found $lcname in \@nameExceptions\n";
            }
            elsif ( $lcname ne lc $FileName ) {
                print "****** ERROR: UpdateConfig $name ne $FileName\n";
            }
            if ( grep( /^$lcname$/, @dataExceptions ) ) {
                #print "Found $lcname in \@dataExceptions\n";
                print OUTPUT "$_";
            }
            elsif ( $num ne $shouldBe and $shouldBe ne "..." ) {
                print "call to updateConfig( $n1'$name', $n2'$num' )\n";
                print "shouldBe updateConfig( $n1'$name', $n2'$shouldBe' )\n";
                #print OUTPUT "  EXECUTE updateConfig $n1'$name', $n2'$shouldBe';\n";
                $thisLine =~ s/$num/$shouldBe/;
                print OUTPUT $thisLine;
                $changed = 1;
            }
            else {
                print OUTPUT "$_";
            }
        }
    }
    else {
        #print "lala\n";
        if ( $inHistory == 1 and !$pastHistory ) {
            if ( /\s+([0-9]+)(st|nd|rd|th)?\s+([A-Za-z]+)\s([0-9]+)\s+([a-zA-Z']+)\s+(.*)$/ ) { #'
                my ($d, $th, $m, $y, $u, $c ) = ($1, $2, $3, $4, $5, $6);
                $c =~ s!^(#\?{5}?) Lint!#00007 Lint!i;
                $c =~ s!^(#\?{4}?) Lint!#0007 Lint!i;
                $c =~ s!^Lint!#0007 Lint!i;
                $c =~ s!^(#\?+) MSVC 8!#10544 MSVC 8!i;
                $c =~ s!^(#\?+) CUpdater!#9528 CUpdater!i;
                $c =~ s!^(#\?+) [- :]+!\1 !i;
                my $date = formatDate($d, $m, $y);
                my $newcomment = getCommentLine($date, $u, $c);
                if ( $_ ne $newcomment ) {
                  print "Old:$_" if ( $verbose );
                  print "new:$newcomment" if ( $verbose );
                  $_ = $newcomment;
                }
            }
            elsif ( /(\s{10,})(.+)$/ ) {
                my $c = $2;
                $c =~ s!^(#\?{5}?) Lint!#00007 Lint!i;
                $c =~ s!^(#\?{4}?) Lint!#0007 Lint!i;
                $c =~ s!^Lint!#0007 Lint!i;
                $c =~ s!^(#\?+) MSVC 8!#10544 MSVC 8!i;
                $c =~ s!^(#\?+) CUpdater!#9528 CUpdater!i;
                $c =~ s!^(#\?+) [- :]+!\1 !i;
                my $newcomment = getCommentLine("", "", $c);
                if ( $_ ne $newcomment ) {
                  print "Old:$_" if ( $verbose );
                  print "new:$newcomment" if ( $verbose );
                  $_ = $newcomment;
                }
            }
            else {
                print "Comment:$_"; # if ( $verbose );
            }
        }
        print OUTPUT "$_";
    }
}

close INPUT;
close OUTPUT;

print "changed: $changed inHistory: $inHistory pastHistory: $pastHistory nComments: $nComments hasComment: $hasComment commented: $commented hasBanner: $hasBanner hasHistory: $hasHistory dodgyBanner: $dodgyBanner\n" if ( $verbose );

# had neither a banner nor a history
if ( $changed == 0 && $hasBanner == 0 && $hasHistory == 0 ) {
    open (INPUT,$infile) or die "can't open $infile\n";
    #print "Will try to open $outfile\n";
    open (OUTPUT,">$outfile") or die "can't open $outfile\n";
    if ( $FirstLine ne "" ) {
        print OUTPUT $FirstLine;
    }
    elsif ( $bom ) {
        print OUTPUT "\x{ef}\x{bb}\x{bf}";
    }
    writeBanner();
    writeHistory();
    my $line = 0;
    while ( <INPUT> ) {
        if ( $line eq 0 ) {
            s/\x{ef}\x{bb}\x{bf}//g;
        }
        if ( $FirstLine eq "" or $line > 0 ) {
            print OUTPUT;
        }
        $line++;
    }
    close INPUT;
    close OUTPUT;
}

# neither a history nor a banner but we updated something else?

elsif ( $changed == 1 && $hasBanner == 0 && $hasHistory == 0 ) {
    rename $outfile, "$outfile.tmp";
    open (INPUT,"$outfile.tmp") or die "can't open $outfile.tmp\n";
    #print "Will try to open $outfile\n";
    open (OUTPUT,">$outfile") or die "can't open $outfile\n";
    if ( $FirstLine ne "" ) {
        print OUTPUT $FirstLine;
    }
    elsif ( $bom ) {
        print OUTPUT "\x{ef}\x{bb}\x{bf}";
    }
    writeBanner();
    writeHistory();
    my $line = 0;
    while ( <INPUT> ) {
        if ( $line eq 0 ) {
            s/\x{ef}\x{bb}\x{bf}//g;
        }
        if ( $FirstLine eq "" or $line > 0 ) {
            print OUTPUT;
        }
        $line++;
    }
    close INPUT;
    close OUTPUT;
    unlink "$outfile.tmp";
}

# had a history which we updated but no banner

elsif ( $changed == 1 && $hasBanner == 0 && $hasHistory == 1 ) {
    rename $outfile, "$outfile.tmp";
    open (INPUT,"$outfile.tmp") or die "can't open $outfile.tmp\n";
    #print "Will try to open $outfile\n";
    open (OUTPUT,">$outfile") or die "can't open $outfile\n";
    if ( $FirstLine ne "" ) {
        print OUTPUT $FirstLine;
    }
    elsif ( $bom ) {
        print OUTPUT "\x{ef}\x{bb}\x{bf}";
    }
    writeBanner();
    my $line = 0;
    while ( <INPUT> ) {
        if ( $line eq 0 ) {
            s/\x{ef}\x{bb}\x{bf}//g;
        }
        if ( $FirstLine eq "" or $line > 0 ) {
            print OUTPUT;
        }
        $line++;
    }
    close INPUT;
    close OUTPUT;
    unlink "$outfile.tmp";
}

# had a banner but no history

elsif ( $hasBanner == 1 && $hasHistory == 0 ) {
    print "Found hasBanner == 1 && hasHistory == 0\n" if ( $verbose );
    rename $outfile, "$outfile.tmp";
    open (INPUT,"$outfile.tmp") or die "can't open $outfile.tmp\n";
    #print "Will try to open $outfile\n";
    open (OUTPUT,">$outfile") or die "can't open $outfile\n";
    #writeBanner();
    my $comments = 0;
    my $writenHistory = 0;
    while ( <INPUT> ) {
        if ( ( $MultiLineEnd ne "" and /^ *\Q$MultiLineEnd\E *$/ ) ||
             ( $SingleLine ne "" and /^ *\Q$SingleLine\E *$/ ) ) {
            #print "end of comments\n";
            $comments++;
            # end of comment?
            print OUTPUT "$_";
            if ( $writenHistory == 0 ) {
                if ( $SingleLine eq "" or $comments eq 2 ) {
                  writeHistory();
                  $writenHistory = 1;
                }
            }
        }
        else {
            print OUTPUT "$_";
        }
    }
    close INPUT;
    close OUTPUT;
    unlink "$outfile.tmp";
}

# had a dodgy banner

elsif ( $dodgyBanner == 1 ) {
    print "Fixing dodgy banner\n"; # if ( $verbose );
    $changed = 1;
    rename $outfile, "$outfile.tmp";
    open (INPUT,"$outfile.tmp") or die "can't open $outfile.tmp\n";
    #print "Will try to open $outfile\n";
    open (OUTPUT,">$outfile") or die "can't open $outfile\n";
    #writeBanner();
    my $past = 0;
    while ( <INPUT> ) {
      if ( $past ) {
          print OUTPUT "$_";
      }
      elsif ( $MultiLineStart ne "" and /^\Q$MultiLineStart\E/ ) {
        print OUTPUT "$MultiLineStart\n";
        print "start of comments\n" if ( $verbose );
      }
      elsif ( $MultiLineEnd ne "" and /\Q$MultiLineEnd\E$/ ) {
        print OUTPUT "$MultiLineEnd\n";
        $past = 1;
        print "end of comments\n" if ( $verbose );
      }
      else {
        if ( /^$ *$/ ) {
          #print OUTPUT "$MultiLinePrefix File: $1\n";
        }
        elsif ( /^\Q$MultiLineEnd\E *File: (.+)/ ) {
          print OUTPUT "$MultiLinePrefix File: $1\n";
        }
        elsif ( /^\Q$MultiLineEnd\E *Author: (.+)/ ) {
          print OUTPUT "$MultiLinePrefix Author: $1\n";
        }
        elsif ( /^\Q$MultiLineEnd\E *Contents: (.+)/ ) {
          print OUTPUT "$MultiLinePrefix Contents: $1\n";
        }
        elsif ( /^\Q$MultiLineEnd\E *Contents:/ ) {
          print OUTPUT "$MultiLinePrefix Contents:\n";
        }
        elsif ( /^\Q$MultiLineEnd\E *Copyright (.+), (.+)/ ) {
          print OUTPUT "$MultiLinePrefix Copyright $1, $2\n";
        }
        elsif ( /^\Q$MultiLinePrefix\E( ?)(.+)/ ) {
          print OUTPUT "$MultiLinePrefix $2\n";
        }
        else {
          print OUTPUT "$_";
        }
      }
    }
    close INPUT;
    close OUTPUT;
    unlink "$outfile.tmp";
}

if ( $changed == 0 && $commented == 1 ) {
    print "No change\n";
    unlink $outfile;
}
else {
    if ( $checkOut eq "Y" ) {
        CheckOut( $infile, $Comments );
    }
    rename $infile, $infile . ".old";
    rename $outfile, $infile;
    if ( $checkIn eq "Y" ) {
        CheckIn( $infile, $Comments );
    }
}

if ( $changeEvent eq "Y" ) {
  chevent($infile, $Comments );
}

sub GetBuildNumber( $ ) {
  my ($drive) = @_;

  my $BuildNoFile = "$drive/topclass/oracle/topclass/sources/buildno.h";
  if ( ! -e $BuildNoFile ) {
      my $VersionInfoFile = "$drive/topclass/oracle/topclass/sources/versioninfo.h";
      if ( -e $VersionInfoFile ) {
          $BuildNoFile = $VersionInfoFile;
      }
      else {
          my $NeoBuildNoFile = "$drive/topclass/neo/sources/buildno.h";
          if ( -e $NeoBuildNoFile ) {
              $BuildNoFile = $NeoBuildNoFile;
          }
          else {
              my $VersionInfoFile = "$drive/topclass/neo/sources/versioninfo.h";
              if ( -e $VersionInfoFile ) {
                  $BuildNoFile = $VersionInfoFile;
              }
          }
      }
  }

  #print "$BuildNoFile\n";

  if ( !open (BUILDNO, $BuildNoFile) ) {
      if ( $fileType eq "sql" && "$Major$Minor$Point$Build$Package" eq "" ) {
          print "**** Cannot open file $BuildNoFile for reading\n";
      }
      return;
  }

  while ( <BUILDNO> ) {
      if ( /\#define BUILDNUMBER +([0-9]+)/ ) {
          $Build = $1;
          #$Build++;
          #$Build--;
      }
      elsif ( /\#define MAJORREVISION +([0-9]+)/ ) {
          $Major = $1;
      }
      elsif ( /\#define MINORREVISION +([0-9]+)/ ) {
          $Minor = $1;
      }
      elsif ( /\#define POINTREVISION +([0-9]+)/ ) {
          $Point = $1;
      }
  }
  close BUILDNO;
  $Build = sprintf( "%03d", $Build );
}

#my $line = "   22nd Feb 2008  eweb     #10850 Removed need for tcencrypt.jar\n";
#print $line;
#$line = map_ids($line);
#print $line;

sub map_ids($$$) {
    my ($line, $changed, $found80000) = @_;
    #print "line: $line\n";
    #print "changed: $$changed\n";
    #print "found80000: $$found80000\n";

    foreach ( $line =~ /#([0-9]{4,5})[^0-9]/g ) {
        #print "[$1] [$_]\n";
        if ( $1 eq "80000" ) {
            $$found80000 = 1;
        }
        #print "[$1] [$_]\n";
        my $old_id = $1;
        my $new_id = $bug_map{$old_id};
        if ( $new_id ne "" ) {
            print "changing from $old_id to $new_id\n";
            $$changed = 1;
            $line =~ s/#$old_id/#$new_id/g;
        }
    }
    #print "line: $line\n";
    #print "changed: $$changed\n";
    #print "found80000: $$found80000\n";
    return $line;
}


sub runCmd($) {
  my ($cmd) = @_;
  print "cmd: $cmd\n";
  if ( open( CMD, "$cmd 2>&1 |" ) ) {
    while ( <CMD> ) {
      print;
    }
    close( CMD );
  }
}

sub chevent($$) {
  my ($file, $comment) = @_;
  if ( $comment eq "" ) {
  }
  elsif ( $scc eq "clearcase" ) {
    # should we verify that the file is checked out?
    my $cmd = "$cctool describe -fmt \"%c\" \"$file\"";
    my $add = 1;
    if ( open( CMT, "$cmd |" ) ) {
      while ( <CMT> ) {
        if ( /\Q$comment\E/ ) {
          $add = 0;
        }
      }
      close( CMT );
    }
    if ( $add ) {
      if ( -d $file ) {
        # for directories we insert...
        runCmd( "$cctool chevent -c \"$comment\" -insert \"$file\"" );
      }
      else {
        runCmd( "$cctool chevent -c \"$comment\" \"$file\"" );
      }
    }
  }
  elsif ( $scc eq "git" ) {
    my $add = 1;
    my $gitmsg = "./.git/GITGUI_MSG";
    if ( open( CMT, $gitmsg ) ) {
      while ( <CMT> ) {
        print if ( $verbose );
        if ( /$comment/ ) {
          $add = 0;
        }
      }
      close( CMT );
    }
    if ( $add ) {
      print "Adding $comment to commit message\n" if ( $verbose );
      if ( open( CMT, ">>$gitmsg" ) ) {
        print CMT "$comment\n";
        close( CMT );
      }
      else {
        print "Error: failed to open $gitmsg $!\n" if ( $verbose );
      }
    }
  }
  elsif ( $scc eq "p4" ) {
    my $found = 0;
    my $added = 0;
    my $cl = `p4 changelists -s pending`;
    if ( $cl =~ /Change ([0-9]+) on / ) {
      $cl = $1;
    }
    else {
      $cl = "";
    }

    if ( open( CMT, "p4 change -o $cl |" ) ) {
      my @lines;
      my $desc;
      foreach ( <CMT> ) {
        if ( $desc ) {
          if ( /^$/ ) {
            if ( !$found and !$added ) {
              @lines = (@lines, "\t$comment\n");
              $added = 1;
            }
            $desc = undef;
          }
          else {
            print if ( $verbose );
            if ( /^\t<enter description here>$/ ) {
              $_ = "\t$comment\n";
              $added = 1;
            }
            elsif ( /\Q$comment\E/ ) {
              $found = 1;
            }
          }
        }
        elsif ( /^Description:/ ) {
          $desc = 1;
        }
        @lines = (@lines, $_);
      }
      close( CMT );
      if ( !$found and $added ) {
        my ($fh, $temp) = File::Temp::tempfile();
        foreach ( @lines ) {
          print $fh $_;
        }
        # each call creates a new change list, need to
        # add to existing.
        my $cmd = "p4 change -i < $temp";
        print "cmd: $cmd\n";
        if ( open( CMT, "$cmd |" ) ) {
          while ( <CMT> ) {
            print;
          }
          close( CMT );
        }
        close( $fh );
      }
    }
  }
}
