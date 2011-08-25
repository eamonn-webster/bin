use strict;
use File::Temp;

my $mnp = $ARGV[0];
my $build = $ARGV[1];
my $view = $ARGV[2];

if ( $mnp eq "" or $build eq "" ) {
  die "Usage $0 mnp build [view]\n";
}

$build = sprintf( "%03d", $build );

my $label = "TC_${mnp}_BUILD_${build}";
$view = "C:/cpp/eweb_snap" unless ( $view );

chdir( $view );

my $cmd;

$cmd = "cleartool catcs";

my ($fh, $tempcs) = File::Temp::tempfile();

#print "$tempcs\n";

my $changed;

  print "$cmd\n";
  if ( open( CMD, "$cmd |" ) ) {
    while ( <CMD> ) {
      if ( /element \* (.+)/ and $1 ne "CHECKEDOUT" ) {
        if ( $1 eq "$label" ) {
          # nought to do
        }
        else {
          s/$1/$label/;
          $changed = 1;
          print $_;
        }
      }
      print $fh $_;
    }
    close( CMD );
  }
close( $fh );

#system( "type $tempcs");

my @keeps;

if ( $changed ) {
  $cmd = "cleartool setcs -overwrite $tempcs";
}
else {
  $cmd = "cleartool update -overwrite";
}
print "$cmd\n";
if ( open( CMD, "$cmd |" ) ) {
  while ( <CMD> ) {
    chomp;
    if ( /^Processing dir/ ) {
    }
    elsif ( /^End dir/ ) {
    }
    elsif ( /^Loading/ ) {
    }
    elsif ( /^Making dir/ ) {
    }
    elsif ( /^Unloaded/ ) {
    }
    elsif ( /^Keeping "(.+)"\./ ) {
      push( @keeps, $1 );
      print "Keeping \"$1\"\n";
    }
    elsif ( /^\.+$/ ) {
    }
    else {
      print "$_\n";
    }
  }
  close( CMD );
}

unlink( $tempcs );
#exit;

$cmd = "for /d %d in (*) do cleartool ls -r %d | grep -v $label | grep -v -e \"-->\"";

$cmd = "for /d %d in (*) do cleartool ls -r %d";

print "$cmd\n";
if ( open( CMD, "$cmd |" ) ) {
  while ( <CMD> ) {
    chomp;
    if ( /Rule: $label/ ) {
    }
    elsif ( /Rule: -none/ ) {
    }
    elsif ( / --> / ) {
    }
    elsif ( /\\lost\+found\@\@ \[not loaded, no version selected\]/ ) {
    }
    else {
      my $line = $_;
      if ( grep( /^\Q$line\E$/, @keeps ) ) {
        print "Removing $line\n";
        unlink( $line );
      }
      else {
        print "$line\n";
      }
    }
  }
  close( CMD );
}

#authoring\lost+found@@ [not loaded, no version selected]
#topclass\lost+found@@ [not loaded, no version selected]
#topclass\oracle\install\distribution\webable\chelp@@ [not loaded, no version selected]   Rule: -none
#topclass\oracle\topclass\Scripts\__DEPRECATED@@ [not loaded, no version selected]        Rule: -none
#utils\lost+found@@ [not loaded, no version selected]

$cmd = "zip -r -o ..\\tc${mnp}b${build}.zip * -xi *.updt";
print "$cmd\n";
if ( open( CMD, "$cmd |" ) ) {
  while ( <CMD> ) {
    if ( /adding:/ ) {
    }
    elsif ( /updating:/ ) {
    }
    else {
      print;
    }
  }
  close( CMD );
}

