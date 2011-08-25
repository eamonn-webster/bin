#!/usr/bin/perl
#
# $Id: reslint.pl,v 1.2 2001/10/23 16:17:22 pbarry Exp $
#
# Check resource file for issues
# Usage:
# reslint.pl [-v] -p <project-name>
#

use Getopt::Std;

my $FIND = "c:\\cygwin\\bin\\find.exe";

getopts('vp:');
$verbose = 1 if ($opt_v);
if ( $opt_p ) {
    $projectName = $opt_p;
} else {
    die "Usage: [-v] -p <project-name>\n-v verbose\n"
    ."./<project-name> should be valid";
}

$file = "./$projectName/src/com/wbtsystems/$projectName/resources.properties";
open RES, "< $file" or die("Huh? Can't load resources $file");
$suppressLint = 0;
while ( <RES> ) {
    $suppressLint = 1 if ( /#\sreslint-/ );
    $suppressLint = 0 if ( /#\sreslint\+/ );

    if ( !$suppressLint ) {
        if ( /^\s*(\w[\w\.]+)=(.*)/ ) {
            if ( defined( $res{$1} ) ) {
                print "[WARN] Duplicate entry $1\n" ;
                if ( $res{$1} ne $2 ) {
                    print " changing from " . $res{$1} . " to $2\n";
                }
            }
            $res{$1} = $2;
        }
        else {
            print "Ignored: $_" if $verbose;
        }
    }
    else {
        print "Suppressed: $_" if $verbose;
    }
}

if ( $verbose ) {
    @t = %res;
    print "List is @t\n";
}

foreach $key ( keys (%res) ) {
    print "find $key in files\n" if $verbose;
    $cmd = "$FIND . -type f -name \"*.jsp*\" -or -name \"*.java\" -or -name \"*.html\" | xargs grep \"$key\"";
    print "$cmd\n\n\n" if $verbose;
    if ( open( F,"$cmd | " ) ) {
        $validfind = 0;
        while ( <F> ) {
            # print "Is it in $_";
            # Look at lines found by findstr to double check
            if ( /[^\w]$key[^\w]/ ) {
                print "$key found in $_" if $verbose;
                $validfind = 1;
                last;
            }
            else {
                print "Ignored partial find of $key in $_" if $verbose;
            }
        }
        close( F );
        if ( !$validfind ) {
            print "[REDUNDANT] \"$key\" not found in any files\n";
        }
    }
}
