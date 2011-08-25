#
# File: codiffs.pl
# Author: eweb
# Copyright WBT Systems, 2003-2011
# Contents: Perl script to do diffs of cheked out files
#
# Date:          Author:  Comments:
# 21st Sep 2007  eweb     #00008 Adapted for p4 and escc.
#  8th Apr 2009  eweb     #00008 Handle existing comments.
# 16th Apr 2009  eweb     #00008 Quote filenames
# 28th May 2009  eweb     #00008 p4 & git
#  2nd Nov 2009  eweb     #00008 git before escc
#  4th Dec 2009  eweb     #00008 Tidy up
# 18th Mar 2010  eweb     #00008 Subversion
# 29th Mar 2010  eweb     #00008 Better handling of multi line comments
#  6th May 2010  eweb     #00008 Don't output auto directory comments
# 31st May 2010  eweb     #00008 Missing last checkout if it has multi-line comment
#  8th Aug 2010  eweb     #00008 Options, first determine scc then set cmds etc
# 19th Aug 2010  eweb     #00008 git options
#  6th Jan 2011  eweb     #00008 Name the identical file
#  7th Feb 2011  eweb     #00008 Handle git new files
# 29th Mar 2011  eweb     #00008 -f filter
#

use strict;
use Cwd;
use Getopt::Std;

my $cctool1 = "cleartool"; # info gathering
my $cctool2 = "cleartool"; # easily reversable
my $cctool3 = "cleartool"; # reversable
my $cctool4 = "cleartool"; # destructive

my $lsco = "$cctool1 lsco -cview -avobs -fmt \"%n [%Nc]\\n\"";
my $diff1 = "$cctool1 diff -pred -serial";
my $diff2 = "$cctool1 diff -pred -serial -options -b";
#$diff1 = $diff2;
my $namepatt = '^(.*) \[(.*)\]$';
my $namepatt2;
my $skipline;
#$namepatt = '^(.*topclass.js)$';

my $listIdents = "N";
#$listIdents = "Y";
my $verbose;
#$verbose = 1;
my $nodiffs;
#$nodiffs = 1;
my $startline;
my $stopline;
my $filter;
my $substPattern;
my $substSubst;
my $editor = "textpad";

my $cwd = getcwd();

print "cwd: $cwd\n" if ($verbose);

my %opts = ( v => undef(),
             o => undef(),
             s => undef(),
             b => undef(),
             f => undef(),
           );

if ( !getopts("v:o:s:bf:", \%opts) or @ARGV > 1 ) {
  print STDERR "Unknown arg $ARGV[0]\n" if @ARGV > 0;
  #Usage();
  exit;
}

my $ignorespace = $opts{b};
my $verbose = $opts{v};
my $scc = $opts{s};
my $options = $opts{o};
my $filter = $opts{f};

$scc = "clearcase" unless ( $scc );

my $output;
my $cosout;

my $drive = "c";
if ( $cwd =~ /^([a-z]):/i ) {
    $drive = lc $1;
}

if ( $cwd =~ /^c:\/p4clients/i or $cwd =~ /^c:\\p4clients/i ) {
    $scc = "p4";
}
elsif ( -d "\\.git" or -d ".git" ) {
    $scc = "git";
}
elsif ( -d "\\.svn" or -d ".svn" ) {
    $scc = "svn";
}
elsif ( $cwd =~ /^c:\/cpp/i or $cwd =~ /^c:\\cpp/i ) {
    $scc = "escc";
}
else {
}

if ( $scc eq "clearcase" ) {
    print "clearcase\n" if ($verbose);
    my $lsco = "$cctool1 lsco -cview -avobs -fmt \"%n [%Nc]\\n\"";
    my $diff1 = "$cctool1 diff -pred -serial";
    my $diff2 = "$cctool1 diff -pred -serial -options -b";
    #$diff1 = $diff2;
    my $namepatt = '^(.*) \[(.*)\]$';
    my $skipline;
}
elsif ( $scc eq "p4" ) {
    print "p4\n" if ($verbose);
    $lsco = "p4 diff -sa";
    $lsco = "p4 opened"; #//depot/wacc/java/acc/test/org/eweb/cpp/CalcTest.java#1 - add change 201 (text)
    $diff1 = "p4 diff";
    $diff2 = "p4 diff -dbwc";
    $namepatt = "^(.+)#[0-9]+ - .+";
    $substPattern = "//depot/";
    $substSubst = "c:/p4clients/floyd/";
    $drive = "p";
}
elsif ( $scc eq "git" ) {
    print "git\n" if ($verbose);
    $lsco = "git status";
    if ( $options eq "all" ) {
      # working tree relative to the named commit (HEAD)
      $diff1 = "git diff HEAD";
      $diff2 = "git diff -w HEAD";
    }
    elsif ( $options eq "cached" ) {
      # staged relative to the named commit (HEAD)
      $diff1 = "git diff --cached";
      $diff2 = "git diff -w --cached";
    }
    else {
      # changes relative to the index
      $diff1 = "git diff";
      $diff2 = "git diff -w";
      $startline = "Changed but not updated";
    }
    $namepatt = "^#\\s+modified:\\s+(.+)";
    $namepatt2 = "^#\\s+new file:\\s+(.+)";
    $skipline = "^#";
    if ( -d "\\.git" ) {
      chdir( "\\" );
    }
}
elsif ( $scc eq "svn" ) {
    print "svn\n" if ($verbose);
    $lsco = "svn status -q";
    $diff1 = "svn diff";
    $diff2 = "svn diff";
    $namepatt = "^[AM].......(.+)";
    $skipline = "^[^AM]";
}
elsif ( $scc eq "escc" ) {
    print "escc\n" if ($verbose);
    $lsco = "escc lsco";
    $diff1 = "escc diff";
    $diff2 = "escc diff";
    $namepatt = "^([^[]+)";
}
else {
    print "unknown scc $scc\n";
}

if ( $output eq "" ) {
    if ( $^O eq "darwin" ) {
      $output = $ENV{HOME} . "/$drive-codiffs.txt";
      $cosout = $ENV{HOME} . "/$drive-cos.sh";
      $editor = "emacs";
    }
    else {
      $output = "c:\\temp\\$drive-codiffs.txt";
      $cosout = "c:\\temp\\$drive-cos.bat";
    }
    print " $editor $output $cosout\n";
}

if ( $output eq "" ) {
    $output = "-";
}

open( OUT, ">$output" );

if ( $cosout ne "" ) {
    open( COSOUT, ">$cosout" );
}

my $addcomment = "addcomment.pl";

if ( open( COS, "$lsco 2>&1 |" ) ) {
    my $skip;
    if ( $startline ne "" ) {
      $skip = 1;
    }
    my $c = 0;
    while ( <COS> ) {
        $c++;
        print "$c: $_" if ( $verbose );
        chomp;
        my $co = $_;
        my $file;
        my $comments;
        if ( $skip ) {
            if ( $co =~ /$startline/ ) {
                $skip = undef;
            }
            else {
                next;
            }
        }
        if ( $substPattern && $substSubst ) {
          $co =~ s!\Q$substPattern\E!$substSubst!;
        }
        if ( $co =~ /$namepatt/s ) {
            $file = $1;
            $comments = $2;
            print "\$file: $file \$comments: $comments\n" if ( $verbose );
        }
        elsif ( $namepatt2 and $co =~ /$namepatt2/s ) {
            $file = $1;
            $comments = $2;
            print "\$file: $file \$comments: $comments\n" if ( $verbose );
        }
        elsif ( $skipline and $co =~ /$skipline/ ) {
            print "Skipping line\n" if ( $verbose );
        }
        else {
            print "continuing line\n" if ( $verbose );
            unless ( eof(COS) ) {
              $_ .= "\n" . <COS>; # separate with a line break
              redo; # unless eof(COS);
            }
        }
        print "checking file $file\n" if ( $verbose );
        if ( $file && -d $file ) {
            # need to extract the non automatic comments...
            # split comment into lines, remove all the auto adding element, uncataloging symlink, etc.
        }
        if ( $filter && $file !~ /$filter/ ) {
          next;
        }
        if ( $comments ) {
            # for each line of comments...
            my @clines = split( /[\n\r]+/, $comments );

            if ( $comments !~ /^#/ ) {
                print COSOUT "    $addcomment -c \"\" -insert \"$file\"\n";
            }
            foreach ( @clines ) {
                s!"!\\"!g;
                if ( -d $file and ( /Added file element/ or /Added directory element/ or /Added symbolic link/ or /Uncataloged directory element/ or /Uncataloged file element/ ) ) {
                    #print COSOUT "REM $addcomment -c \"$_\" \"$file\"\n";
                }
                else {
                    print COSOUT "REM $addcomment -c \"$_\" \"$file\"\n";
                }
            }
        }
        else {
            if ( -d $file ) {
                print COSOUT "    $addcomment -c \"\" -insert \"$file\"\n";
            }
            elsif ( -e $file ) {
                print COSOUT "    $addcomment -c \"\" \"$file\"\n";
            }
        }
        if ( $nodiffs ) {
        }
        elsif ( $file ) {
            my $cmd = "$diff1 \"$file\"";
            if ( $ignorespace ) {
                $cmd = "$diff2 \"$file\"";
            }
            print "$cmd\n" if ( $verbose );
            if ( open( DIFF, "$cmd 2>&1 |" ) ) {
                while ( <DIFF> ) {
                    s/[\r\n]+$//;
                    if ( /^Files are identical$/ or /^Directories are identical$/ ) {
                        print OUT "$file: $_\n";
                        if ( $listIdents eq "Y" ) {
                            print OUT "$file\n";
                            CheckIn( $file, "" );
                        }
                        else {
                            last;
                        }
                    }
                    elsif ( /^old mode/ or /^new mode/ ) {
                    }
                    else {
                        if ( $_ ne "" ) {
                            print OUT "$_\n";
                        }                        
                    }
                }
                close( DIFF );
            }
        }
    }
    close( COS );
}

if ( $listIdents eq "Y" and $diff1 ne $diff2 ) {
    if ( open( COS, "$lsco 2>&1 |" ) ) {
        while ( <COS> ) {
            chomp;
            if ( /$namepatt/ ) {
                my $file = $1;
                if ( $nodiffs ) {
                }
                elsif ( open( DIFF, "$diff2 $file 2>&1 |" ) ) {
                    while ( <DIFF> ) {
                        if ( $listIdents eq "Y" ) {
                            if ( /^Files are identical$/ ) {
                                print OUT "$file\n";
                                CheckIn( $file, "#????? White space" );
                            }
                            else {
                                last;
                            }
                        }
                        else {
                            print OUT $_;
                        }
                    }
                    close( DIFF );
                }
            }
        }
        close( COS );
    }
}

close( OUT );
close( COSOUT );

sub CheckIn($$) {
    my ($file, $comment) = @_;

    my $cmd;
    if ( $comment ne "" ) {
        $cmd = "$cctool2 ci -c \"$comment\" $file";
    }
    else {
        $cmd = "$cctool2 ci -nc $file";
    }
    print OUT "$cmd\n";
    my $results = `$cmd 2>&1`;

    if ( $results =~ /Error: By default, won't create version with data identical to predecessor./ ) {
        # hasn't changed so undo the check out.
        $cmd = "$cctool4 unco -rm $file";
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
    print OUT "$results\n";
}
