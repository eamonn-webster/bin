use strict;

use Getopt::Std;
use Time::Local;

my %opts = ( t => undef(),
             d => undef(),
             );

if ( !getopts("t:d:", \%opts) or @ARGV > 1 )
  {
    print STDERR "Unknown arg $ARGV[0]\n" if @ARGV > 0;
    #Usage();
    exit;
  }

my $arg;

my $targ = $opts{t};
my $darg = $opts{d};

my @tparts = ( $targ =~ /([0-9]+):([0-9]+):([0-9]+)/ );
my @dparts = ( $darg =~ /([0-9]+)\/([0-9]{2})\/([0-9]{4})/ );

my ($hour, $min, $sec) = @tparts;
my ($mday, $mon, $year) = @dparts;

my $time = timelocal($sec,$min,$hour,$mday,$mon-1,$year);
for $arg ( @ARGV )
  {
    for my $file ( glob( "$arg" ) )
      {
        print "$file\n";
        utime $time, $time, $file;
      }
  }


