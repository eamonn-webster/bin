#
# File: copycos.pl
# Copy the checked out files to a different directory
#

use strict;
use File::Glob;
use File::Copy;
use File::Basename;

my $ViewTag = $ARGV[0];
my $KeepDir = $ARGV[1];


if ( $ViewTag eq "" or $ViewTag eq "." ) {
  chomp($ViewTag = `cleartool lsview -cview  -short`);
}
if ( $KeepDir eq "" ) {
  $KeepDir = "c:\\cpp\\keep";
}
#my $copyfiles = "copyprivs.txt";

#open( COPYLOG, ">$copyfiles" ) or die "Can't open $copyfiles\n";

if ( ! -d $KeepDir ) {
  MkDir( $KeepDir );
}

if ( -d "$KeepDir\\$ViewTag" ) {
  my $i = 1;
  while ( -d "$KeepDir\\$ViewTag.$i" ) {
    $i++;
  }
  run( "move \"$KeepDir\\$ViewTag\" \"$KeepDir\\$ViewTag.$i\"" );
}

MkDir( "$KeepDir\\$ViewTag" );

system( "cleartool catcs -tag $ViewTag > $KeepDir\\$ViewTag\\config.spec" );

open( PRIVATES, "cleartool lspriv -tag $ViewTag |");

while ( <PRIVATES> )
  {
    #print;
    chomp;
    if ( /(.*)  \[checkedout\]/ )
      {
        my $file = $1;
        #print "[$file]\n";
        #$file =~ s/M:\\$ViewTag//;

        #if ( $file =~ /M:\\$ViewTag(.+)/ )
        #  {
        #    copyFile( $file, "$KeepDir$1", "/p" );
        #  }
        #els
        if ( $file =~ /.:(.+)/ )
          {
            copyFile( $file, "$KeepDir$1", "/p" );
          }
      }
  }

close(PRIVATES);
close(COPYLOG);

sub copyFile()
  {
    my ($source, $dest, $flags) = @_;

    print "copy $flags $source $dest\n";

    my ($nameS, $pathS, $suffixS) = fileparse($source);
    my ($nameD, $pathD, $suffixD) = fileparse($dest);

    #print "Source ($nameS, $pathS, $suffixS)\n";
    #print "Dest   ($nameD, $pathD, $suffixD)\n";

    if ( $flags eq "/p" )
      {
        if ( !-d $pathD )
          {
            MkDir( $pathD );
          }
      }

    if ( -e $dest )
      {
        # copying to a file that exists?
      }
    if ( -e $source )
      {
        my $destFile = $dest;
        if ( -d $dest )
          {
            # copying to a directory
            $destFile = "$dest\\$nameS$suffixS";
          }
        elsif ( $nameD eq "" )
          {
            #destination is a directory
            MkDir( $dest );
            $destFile = "$dest\\$nameS$suffixS";
          }
        else
          {
            if ( $nameS =~ /\./ )
              {
                if ( $nameD !~ /\./ )
                  {
                    print "**** Perhaps destination $dest is a directory\n";
                    print "**** Perhaps destination $dest is a directory\n";
                  }
              }
          }
        if ( copy( $source, $destFile ) )
          {
            print "$source => $destFile\n";
          }
        else
          {
            print "**** $source => $destFile FAILED $!\n";
          }
      }
    elsif ( -d $source )
      {
        print "?????? copy directory $source $dest\n";
      }
    elsif ( $source =~ /[\?\*]/ ) # globbing
      {
        print "copy glob $source $dest\n";
        my @sources = File::Glob::bsd_glob( $source );
        if ( $#sources == 0 )
          {
            print "**** $source no files\n";
          }
        else
          {
            MkDir( $dest );
            foreach (@sources)
              {
                my ($name, $path, $suffix) = fileparse($_);
                if ( copy( $_, "$dest\\$name$suffix" ) )
                  {
                    print "$_ => $dest\\$name$suffix\n";
                  }
                else
                  {
                    print "**** $_ => $dest\\$name$suffix FAILED $!\n";
                  }
              }
          }
      }
    else
      {
        print "**** $source file not found\n";
      }

    if ( $flags eq "/s" or $flags eq "/e" )
      {
        my ($name, $srcDir, $suffix) = fileparse($source);
        my $dir;
        if ( opendir( $dir, $srcDir) )
          {
            my $subdir;
            while ( defined( $subdir = readdir($dir) ) )
              {
                if ( $subdir eq "." or $subdir eq ".." )
                  {
                  }
                elsif ( -d "$srcDir$subdir" )
                  {
                    #MakeDirectory( "$dest\\$subdir" );
                    copyFile( "$srcDir$subdir\\$name$suffix", "$dest\\$subdir", $flags );
                  }
              }
            closedir($dir);
          }
      }
  }

sub MkDir($)
  {
    my ($dir) = @_;
    if ( -d $dir )
      {
        #print "MkDir $dir exists\n";
      }
    else
      {
        my $sofar = "";
        foreach ( split( /\\/, $dir ) )
          {
            if ( $sofar eq "" )
              {
                $sofar = $_;
              }
            else
              {
                $sofar = "$sofar\\$_";
                if ( -d $sofar )
                  {
                    #print "MkDir $sofar exists\n";
                  }
                else
                  {
                    #print "calling mkdir( $sofar )\n";
                    if ( mkdir( $sofar ) )
                      {
                        #print "MkDir $dir succeeded\n";
                      }
                    else
                      {
                        print "MkDir $sofar FAILED! $!\n";
                        return 0;
                      }
                  }
              }
          }
        #print "MkDir $dir\n";
      }
  }

sub run($) {
  my ($cmd) = @_;
  print "cmd: $cmd\n";
  system( $cmd );
}

