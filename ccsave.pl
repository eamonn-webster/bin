#
# File: ccsave.pl
# Author: eweb
# Copyright WBT Systems, 1995-2010
# Contents:
#
# Date:          Author:  Comments:
# 29th Mar 2010  eweb     #00008 save/restore clearcase views
# 30th Mar 2010  eweb     #00008 Save restore checkouts
# 31st Mar 2010  eweb     #00008 Spaces in filenames
#  8th Apr 2010  eweb     #00008 lsview -host -quick is case sensitive
#  8th Apr 2010  eweb     #00008 views that aren't running
#  8th Apr 2010  eweb     #00008 Use USERPROFILE instead of TEMP
#  8th Apr 2010  eweb     #00008 slashes, scriptdir and perlexe
# 27th May 2010  eweb     #00008 command switches, check mode, osify, logging
# 17th Sep 2010  eweb     #00007 $#array returns last index
#

use strict;
use Cwd;
use File::Glob;
use File::Copy;
use File::Basename;
use Getopt::Std;

my %opts = ( v => undef(),
             t => undef(),
             s => undef(),
             R => undef(),
             K => undef(),
             M => undef(),
           );

if ( !getopts("vtsR:K:M:", \%opts) or @ARGV > 1 ) {
    print STDERR "Unknown arg $ARGV[0]\n" if @ARGV > 0;
    #Usage();
    exit;
}

my $action = $ARGV[0];

my $removeViews = $opts{R};
my $startViews = $opts{s};
my $cmd;

my $host = lc $ENV{COMPUTERNAME};

my $verbose = $opts{v};
my $testing = $opts{t};

my ($self, $scriptDir) = fileparse($0);

print "\$0; $0\n" if ( $verbose );
print "\$self: $self\n" if ( $verbose );
print "\$scriptDir: $scriptDir\n" if ( $verbose );

sub osify($)
{
  my ($path) = @_;
  if ( $^O eq "MSWin32" )
    {
      $path =~ s!/!\\!g;
    }
  else
    {
      $path =~ s!\\!/!g;
    }
  return $path;
}

  if ( $action eq "" ) {
    print "usage perl $0 save|restore|check\n";
    print " -v verbose\n";
    print " -t testing\n";
    print " -s startViews\n";
    print " -R [Y/N] Remove views\n";
    print " -K <keepdir>\n";
    print " -M <viewRoot> [M:]\n";
    exit;
  }

my $keepdir = $opts{K};
$keepdir = osify( $ENV{USERPROFILE} . "/ccsave" ) if ( $keepdir eq "" );
my $viewRoot = $opts{M};
$viewRoot = "M:" if ( $viewRoot eq "" );

if ( ! -d $keepdir ) {
  mkdir( $keepdir );
}
if ( ! -d $keepdir ) {
  die "Can't create keepdir $keepdir $!\n";
}

if ( $action eq "check" ) {
  $cmd = "cleartool lsview -short -host $host -quick";

  $cmd = "cleartool lsview";

  print "cmd: $cmd\n" if ( $verbose );

  # for each view on the host
  if ( open( VIEWS, "$cmd |" ) ) {
    while ( <VIEWS> ) {
      if ( /\*?\s+([^ ]+)\s+\\\\([^\\]+)\\/ ) {
        if ( lc $2 ne lc $host ) {
          #print "view on $2\n";
          next;
        }
        my $startedView;
        my $view = $1;
        if ( ! -d osify("$viewRoot/$view") and $startViews eq "y" ) {
          $cmd = "cleartool startview $view";
          #print "cmd: $cmd\n";
          runcmd( $cmd );
          $startedView = 1;
          if ( ! -d osify("$viewRoot/$view") ) {
            print "ERROR: failed to start view $view\n";
          }
        }
        if ( -d osify("$viewRoot/$view") ) {
          chdir( osify("$viewRoot/$view") );
          print getcwd() . "\n" if ( $verbose );
          $cmd = "cleartool lsco -avobs -cview";
          print "cmd: $cmd\n" if ( $verbose );
          my $cos = `$cmd`;
          if ( $cos ne "" ) {
            print "View $view has checkouts\n";
            print $cos;
          }
          else {
            print "View $view has no checkouts\n";
          }
          $cmd = "cleartool lsprivate";
          print "cmd: $cmd\n" if ( $verbose );
          my $privs = `$cmd`;
          if ( $privs ne "" ) {
            print "View $view has view private files\n";
            print $privs;
          }
          else {
            print "View $view has no view private files\n";
          }
        }
      }
    }
  }
}

if ( $action eq "save" ) {

  print "Saving to $keepdir\n";
  my %subst;

  if ( open( SUBST, "subst |" ) ) {
    while ( <SUBST> ) {
      if ( /(.):\\: => M:\\(.+)/ ) {
        $subst{$2} = $1;
        print "$2 $1:\n" if ( $verbose );
      }
    }
    close( SUBST );
  }
  if ( open( SUBST, "net use |" ) ) {
    while ( <SUBST> ) {
      if ( /(.):\s+\\\\view\\([^ ]+)/ ) {
        $subst{$2} = $1;
        print "$2 $1:\n" if ( $verbose );
      }
    }
    close( SUBST );
  }

  $cmd = "cleartool lsview -short -host $host -quick";

  $cmd = "cleartool lsview";

  print "cmd: $cmd\n" if ( $verbose );

  # for each view on the host
  if ( open( VIEWS, "$cmd |" ) ) {
    while ( <VIEWS> ) {
      if ( /\*?\s+([^ ]+)\s+\\\\([^\\]+)\\/ ) {
        if ( lc $2 ne lc $host ) {
          #print "view on $2\n";
          next;
        }
        my $startedView;
        my $view = $1;
        if ( ! -d osify("$viewRoot/$view") and $startViews eq "y" ) {
          $cmd = "cleartool startview $view";
          #print "cmd: $cmd\n";
          runcmd( $cmd );
          $startedView = 1;
          if ( ! -d osify("$viewRoot/$view") ) {
            print "ERROR: failed to start view $view\n";
          }
        }
        if ( -d osify("$viewRoot/$view") ) {
          chdir( osify("$viewRoot/$view") );
          $cmd = "cleartool lsco -avobs -cview";
          print "cmd: $cmd\n" if ( $verbose );
          my $cos = `$cmd`;
          if ( $cos ne "" ) {
            print "View $view has checkouts\n";
            #print $cos;
            #next;
          }
        }
        my $drive = $subst{$view};
        print "view: $view drive: $drive\n";
        mkdir( osify("$keepdir/$view") );
        # save the config spec
        $cmd = "cleartool catcs -tag $view > \"" . osify( "$keepdir/$view/configspec.txt" ) . "\"";
        #print "cmd: $cmd\n" if ( $verbose );
        runcmd( $cmd );
        if ( $drive ) {
          $cmd = "echo net use $drive: \\\\view\\$view > \"" . osify( "$keepdir/$view/net_use.bat" ) . "\"";
          #print "cmd: $cmd\n" if ( $verbose );
          runcmd( $cmd );
        }

        if ( -d osify("$viewRoot/$view") ) {
          copyCheckouts( $view, $keepdir );
        }

        if ( $startedView or $removeViews eq "Y" ) {
          $cmd = "cleartool endview $view";
          #print "cmd: $cmd\n";
          runcmd( $cmd );
        }
        if ( $removeViews eq "Y" ) {
          $cmd = "cleartool rmview -tag $view";
          #print "cmd: $cmd\n";
          runcmd( $cmd );
        }
      }
    }
    close( VIEWS );
  }
}

# save any checkouts
# save any view privates
# undo checkouts
# stop the view
# remove the view


# then run ccrestore
if ( $action eq "restore" ) {
  print "Restoring from $keepdir\n";

  my $mkview = osify("$scriptDir/mkview.pl");

  $mkview = "\"$^X\" \"$mkview\"";

  if ( opendir( DIRH, $keepdir ) ) {
    while ( my $x = readdir(DIRH) ) {
    #while ( readdir(DIRH) ) {
    #while ( defined( my $x = readdir(DIRH) ) ) {
    #while ( readdir(DIRH) ) {
      if ( $x eq "." or $x eq ".." ) {
      }
      else {
        my $cs = osify("$keepdir/$x/configspec.txt");

        if ( -e $cs ) {
          #print "dir: $x\n";
          $cmd = "$mkview $x . n";
          #print "$cmd\n";
          runcmd( $cmd ) unless ( $testing );

          $cmd = "cleartool setcs -tag $x \"$cs\"";
          #print "$cmd\n";
          runcmd( $cmd ) unless ( $testing );

          if ( -e "$keepdir\\$x\\net_use.bat" ) {
            $cmd = "\"$keepdir\\$x\\net_use.bat\"";
            #print "$cmd\n";
            runcmd( $cmd ) unless ( $testing );
          }
          if ( -d "$keepdir\\$x\\$x" ) {
            print "Files to check out\n";
            checkoutCopies( $x, $keepdir );
          }
        }
      }
    }
    closedir(DIRH);
  }
}

# for each view above
# create the view
# set the config spec
# assign drive mapping
# copy over view privates
# check out saved check outs

sub copyCheckouts($$) {
  my ($view, $keepdir) = @_;

  my $cmd = "cleartool lspriv -tag $view";
  print "cmd: $cmd\n";
  if ( open( PRIVATES, "$cmd |") ) {
    while ( <PRIVATES> ) {
      #print;
      chomp;
      if ( /(.*)  \[checkedout\]/ ) {
        my $file = $1;
        if ( $file =~ /.:(.+)/ ) {
          # view appears twice on purpose...
          copyFile( $file, "$keepdir/$view/$1", "/p" );
        }
      }
    }
    close(PRIVATES);
  }
}

sub copyFile($$;$) {
  my ($source, $dest, $flags) = @_;

  $source = osify($source);
  $dest = osify($dest);

  print "copy $flags $source $dest\n";

  my ($nameS, $pathS, $suffixS) = fileparse($source);
  my ($nameD, $pathD, $suffixD) = fileparse($dest);

  #print "Source ($nameS, $pathS, $suffixS)\n";
  #print "Dest   ($nameD, $pathD, $suffixD)\n";

  if ( $flags eq "/p" ) {
    if ( !-d $pathD ) {
      MkDir( $pathD );
    }
  }

  if ( -e $dest ) {
    # copying to a file that exists?
  }
  if ( -e $source ) {
    my $destFile = $dest;
    if ( -d $dest ) {
      # copying to a directory
      $destFile = osify("$dest/$nameS$suffixS");
    }
    elsif ( $nameD eq "" ) {
      #destination is a directory
      MkDir( $dest );
      $destFile = osify("$dest/$nameS$suffixS");
    }
    else {
      if ( $nameS =~ /\./ ) {
        if ( $nameD !~ /\./ ) {
          print "**** Perhaps destination $dest is a directory\n";
        }
      }
    }
    if ( copy( $source, $destFile ) ) {
      print "$source => $destFile\n";
    }
    else {
      print "**** $source => $destFile FAILED $!\n";
    }
  }
  elsif ( -d $source ) {
    print "?????? copy directory $source $dest\n";
  }
  elsif ( $source =~ /[\?\*]/ ) { # globbing
    print "copy glob $source $dest\n";
    my @sources = File::Glob::bsd_glob( $source );
    if ( $#sources == -1 ) {
      print "**** $source no files\n";
    }
    else {
      MkDir( $dest );
      foreach (@sources) {
        my ($name, $path, $suffix) = fileparse($_);
        my $destFile = osify("$dest/$name$suffix");
        if ( copy( $_, $destFile ) ) {
          print "$_ => $destFile\n";
        }
        else {
          print "**** $_ => $destFile FAILED $!\n";
        }
      }
    }
  }
  else {
    print "**** $source file not found\n";
  }

  if ( $flags eq "/s" or $flags eq "/e" ) {
    my ($name, $srcDir, $suffix) = fileparse($source);
    my $dir;
    if ( opendir( $dir, $srcDir) ) {
      my $subdir;
      while ( defined( $subdir = readdir($dir) ) ) {
        if ( $subdir eq "." or $subdir eq ".." ) {
        }
        elsif ( -d "$srcDir$subdir" ) {
          copyFile( osify("$srcDir$subdir/$name$suffix"), osify("$dest/$subdir"), $flags );
        }
      }
      closedir($dir);
    }
  }
}

sub MkDir($) {
  my ($dir) = @_;
  if ( -d $dir ) {
    #print "MkDir $dir exists\n";
  }
  else {
    my $sofar = "";
    foreach ( split( /[\\\/]/, $dir ) ) {
      if ( $sofar eq "" ) {
        $sofar = $_;
      }
      else {
        $sofar = osify("$sofar/$_");
        if ( -d $sofar ) {
          #print "MkDir $sofar exists\n";
        }
        else {
          #print "calling mkdir( $sofar )\n";
          if ( mkdir( $sofar ) ) {
            #print "MkDir $dir succeeded\n";
          }
          else {
            print "MkDir $sofar FAILED! $!\n";
            return 0;
          }
        }
      }
    }
    #print "MkDir $dir\n";
  }
}


sub checkoutCopies($$) {
  my ($view, $keepdir) = @_;

  my $copies = osify( "$keepdir/$view/" );

  my $cmd = "dir /s /b /a-d \"$copies$view\"";
  print "cmd: $cmd\n";
  if ( open( COPIES, "$cmd |") ) {
    while ( <COPIES> ) {
      #print;
      chomp;
      my $file = $_;
      if ( $file =~ /\Q$copies\E(.+)/ ) {
        my $dest = osify("$viewRoot/$1");
        # view appears twice on purpose...
        $cmd = "cleartool co -nc \"$dest\"";
        #print "$cmd\n";
        runcmd( $cmd );

        copyFile( $file, $dest );
      }
    }
    close(COPIES);
  }
}

sub runcmd( $ )
  {
    my ($cmd) = @_;
    print "$cmd\n";
    my $cmdout;
    if ( open( $cmdout, "$cmd 2>&1 |" ) )
      {
        while ( <$cmdout> )
          {
            print;
          }
        close( $cmdout );
      }
  }

