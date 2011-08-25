#******************************************************************************
#
#  File: checkdata.pl
#  Author: eweb
#  Copyright eweb, 2007-2007
#  Contents: Check data files and zips
#
#******************************************************************************
#
# Date:          Author:  Comments:
#  4th Jul 2007  eweb     Lower case names, check dates, check directory.
#

use strict;
use File::Find;
use File::Basename;
use File::stat;

sub lowerEach ()
{
  #print "$File::Find::name\n";
  #my ($name,$path,$suffix) = fileparse($File::Find::name, qr/\.[^.]*/);

  if ( $_ eq uc $_ && $_ ne lc $_ )
    {
      print "$_\n";
      rename( $_, lc $_ );
    }
}

find( \&lowerEach, "." );

sub moveZips ()
{
  if ( -d $_ )
    {
      #is it empty?
      my @contents = <$_/*>;
      #print "$File::Find::dir/$_ contains @contents\n";
      if ( $#contents > -1 )
        {
          #print "$_ is not empty\n";
        }
      else
        {
          print "$File::Find::dir/$_ is empty\n";
          rmdir( $_ );
        }

    }
  elsif ( /\.zip$/ )
    {
      my ($name,$path,$suffix) = fileparse($File::Find::name, qr/\.[^.]*/);

      #print "$path - $name - $suffix\n";

      my $ddd;
      my $year;
      my $mon;
      my $dd;
      if ( /^(...)([0-9]{4})([a-zA-Z]{3})([0-9]{2})\.zip$/ )
        {
          $ddd = $1;
          $year = $2;
          $mon = $3;
          $dd = $4;
          if ( $mon ne ucfirst $mon )
            {
              print "$_\n";
              $mon = ucfirst $mon;
              rename( $_, "$ddd$year$mon$dd.zip" );
              $_ = "$ddd$year$mon$dd.zip";
            }

          if ( ! -e $_ )
            {
              print "$_ doesn't exist\n";
              return;
            }
          my $sb = stat($_);
          if ( $sb eq "" )
            {
              print "stat($_) => NULL\n";
              return;
            }
          #print "stat($_) => $sb\n";
          my $tt = localtime $sb->mtime;

          #print "$tt\n";

          my @t = localtime $sb->mtime;
          my $y = $t[5]+1900;
          my $d = sprintf "%02d", $t[3];
          my $m = $mon;
          if ( $tt =~ /[^ ]+ +([^ ]+)+ / )
            {
              $m = $1;
            }


          if ( $year ne $y or $mon ne $m or $dd ne $d )
            {
              print "$_: $tt.";
              if ( $year ne $y )
                {
                  print " $year ne $y";
                }
              if ( $mon ne $m )
                {
                  print " $mon ne $m";
                }
              if ( $dd ne $d )
                {
                  print " $dd ne $d";
                }
              print "\n";

              print "$ddd$y$m$d.zip\n";

              $year = $y;
              $mon = $m;
              $dd = $d;
            }

          if ( $_ ne "$ddd$year$mon$dd.zip" )
            {
              print "rename $_ $ddd$year$mon$dd.zip\n";
              rename( $_, "$ddd$year$mon$dd.zip" );
              $_ = "$ddd$year$mon$dd.zip";
            }

          if ( $path =~ /\/$year\/$year/ )
            {
              my $cmd = "move $_ ..";
              print "$cmd\n";
              system( $cmd );
            }
          elsif ( $path =~ /\/zippers\/([0-9]{4})/ && $1 ne $year )
            {
              # in the wrong directory, so move up
              my $cmd = "move $_ ..";
              print "$cmd\n";
              system( $cmd );
            }
          elsif ( $path =~ /\/zippers\/$year/ )
            {
              if ( $path =~ /\/zippers\/$year\/$year/ )
                {
                  my $cmd = "move $_ ..";
                  print "$cmd\n";
                  system( $cmd );
                }
            }
          elsif ( $path !~ /\/zippers\// )
            {
              if ( !-d "zippers" )
                {
                  print "mkdir zippers\n";
                  mkdir( "zippers" );
                }
              my $cmd = "move $_ zippers\\$ddd$year$mon$dd.zip";
              print "$cmd\n";
              if ( -d "zippers" )
                {
                  system( $cmd );
                }
            }
          else
            {
              if ( ! -d "$year" )
                {
                  print "mkdir $year\n";
                  mkdir( "$year" );
                  if ( ! -d "$year" )
                    {
                      die "mkdir $File::Find::name/$year failed\n";
                    }
                }
              my $cmd = "move $_ $year\\$ddd$year$mon$dd.zip";
              print "$cmd\n";
              if ( -d $year )
                {
                  system( $cmd );
                }
            }
        }
      elsif ( /^(...)\.zip$/ )
        {
          $ddd = $1;
          #$year = $2;
          #$mon = $3;
          #$dd = $4;
          # should be in the main directory not zippers...
          if ( $path =~ /\/zippers\// )
            {
              print "Rename or remove $path$name$suffix\n";
            }
        }
      elsif ( /^(...)([a-zA-Z]{3})([0-9]{2})\.zip$/ )
        {
          $ddd = $1;
          #$year = $2;
          $mon = $2;
          $dd = $3;
          if ( $mon ne ucfirst $mon )
            {
              print "$_\n";
              $mon = ucfirst $mon;
              rename( $_, "$ddd$mon$dd.zip" );
              $_ = "$ddd$mon$dd.zip";
            }
          #print "$_ - No year\n";
          my $sb = stat($_);
          #print "$_ @s\n";
          my @t = localtime $sb->mtime;
          $year = $t[5]+1900;
          print "$_: $year\n";
          rename( $_, "$ddd$year$mon$dd.zip" );
          $_ = "$ddd$year$mon$dd.zip";
        }
      else
        {
          print "$_\n";
        }
    }
}

find( \&moveZips, "." );
