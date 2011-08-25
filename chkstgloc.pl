use strict;
use Getopt::Std;

my %opts = ( v => undef(),
             f => undef(),
             h => undef(),
           );

my $chview;
my $single_host;
my $verbose;

my %lookup;
my %stglocalpath;
my %stgglobalpath;


if ( !getopts("vxh:", \%opts) or @ARGV > 0 )
  {
    print STDERR "Unknown arg $ARGV[0]\n\n" if @ARGV > 0;
    print STDERR "Usage perl $0 options\n";
    print STDERR " -h <host>  host to check\n";
    print STDERR " -v         verbose \n";
    print STDERR " -x         fix \n";
    #Usage();
    exit;
  }

if ( defined($opts{h}) )
  {
    $single_host = lc $opts{h};
  }
if ( defined($opts{v}) )
  {
    $verbose = lc $opts{v};
  }
if ( defined($opts{x}) )
  {
    $chview = 1;
  }

$single_host = lc $ENV{COMPUTERNAME} if ( $single_host eq "localhost" );
$single_host = lc $ENV{COMPUTERNAME} if ( $single_host eq "" );

my $cmd = "cleartool lsstgloc";

if ( open( STGLOCS, "$cmd |") ) {
  while ( <STGLOCS> ) {
    if ( /^\s+([^ ]+)\s+\\\\([^\\]+)\\(.+)/ ) {
      my $host = lc $2;
      my $stgloc = $1;
      print "$stgloc on $host\n" if ( $verbose );
      if ( $lookup{$host} ) {
      }
      else {
        if ( $single_host ne "*" and $single_host ne $host ) {
          print "ignoring $host\n" if ( $verbose );
        }
        else {
          my ($name,$aliases,$addrtype,$length,@addrs) = gethostbyname( $host );
          if ( $name ) {
            #print "($name,$aliases,$addrtype,$length,@addrs)\n";
            $lookup{$host} = $name;
            $cmd = "cleartool lsstgloc -long $stgloc";
            if ( open( STGLOC, "$cmd |") ) {
              while ( <STGLOC> ) {
                if ( /Global path: (.+)/ ) {
                  $stgglobalpath{$host} = $1;
                }
                elsif ( /Server host path: (.+)/ ) {
                  $stglocalpath{$host} = $1;
                }
              }
              close( STGLOC );
            }
          }
          else {
            print "Host $host not found\n";
            $lookup{$host} = "-";
          }
        }
      }
    }
  }
  close( STGLOCS );
}

$cmd = "cleartool lsview";
if ( $single_host ne "*" ) {
  $cmd = "$cmd -host $single_host";
}


if ( open( VIEWS, "$cmd |") ) {
  while ( <VIEWS> ) {
    if ( /^. ([^ ]+)\s+\\\\([^\\]+)\\(.+)/ ) {
      my $tag = $1;
      my $host = lc $2;
      my $path = $3;
      print "$tag at $path on $host\n" if ( $verbose );
      $host =~ s!\..+!!;
      if ( $lookup{$host} eq "-" ) {
        print "Host $host not found\n";
      }
      elsif ( $lookup{$host} eq "?" ) {
        print "Host $host not available right now\n" if ( $verbose );
      }
      elsif ( $lookup{$host} ) {
        print "$tag on $host\n";
        my $gpath;
        $cmd = "cleartool lsview -long -properties -full $tag";
        if ( open( VIEW, "$cmd 2>&1 |") ) {
          while ( <VIEW> ) {
#cleartool: Error: Unable to contact albd_server on host 'darwin'
#cleartool: Error: Unable to get view handle: error detected by ClearCase subsystem.
            if ( /cleartool: Error: Unable to contact albd_server on host/ ) {
              print;
              $lookup{$host} = "?";
            }
#Tag: eweb_sundance
#  Global path: \\sundance\ccstg_c\views\eweb_sundance.vws
#  Server host: sundance
#  Region: windows
#  Active: NO
#  View tag uuid:7d529408.34e048dd.9834.69:fb:dd:3e:2f:e2
#View on host: sundance
#View server access path: c:\ClearCase_Storage\views\eweb_sundance.vws
#View uuid: 7d529408.34e048dd.9834.69:fb:dd:3e:2f:e2
#View owner: WBT\eweb
#Created 2010-11-03T16:20:18Z by WBT\eweb.WBT\Domain Users@sundance
#Last modified 2010-11-03T16:20:18Z by WBT\eweb.WBT\Domain Users@sundance
#Last accessed 2010-11-03T16:20:18Z by WBT\eweb.WBT\Domain Users@sundance
#Text mode: msdos
#Owner: WBT\eweb         : rwx (all)
#Group: WBT\Domain Users : rwx (all)
#Other:                  : r-x (read)
#Additional groups: BUILTIN\Administrators BUILTIN\Users WBT\ccusers WBT\Domain Admins nobody
            elsif ( /Tag: (.+)/ ) {
              #$tag = $1;
            }
            elsif ( /Global path: (.+)/ ) {
              $gpath = $1;
            }
            elsif ( /View server access path: (.+)/ ) {
              my $path = $1;
              if ( $path =~ /^\\\\/ ) {
                print "Warning: view $tag on $host has unc hpath $path\n";
                my $loclocal = $stgglobalpath{$host};
                my $locglobal = $stglocalpath{$host};
                #print "\$loclocal: $loclocal \$locglobal: $locglobal \$path: $path\n";
                $path =~ s!\Q$loclocal\E!$locglobal!;
                #print "\$path: $path\n";
                $cmd = "cleartool register -view -replace -host $host -hpath $path $gpath";
                print "$cmd\n";
                if ( $chview and open( CHVIEW, "$cmd 2>&1 |" ) ) {
                  while ( <CHVIEW> ) {
                    print;
                  }
                  close( CHVIEW );
                }
              }
            }
            elsif ( /Text mode: (.+)/ ) {
              my $mode = $1;
              if ( $mode != "msdos" ) {
                print "ERROR view $tag on $host not msdos\n";
              }
            }

            #print;
          }
          close( VIEW );
        }
      }
      else {
        print "No view storage on $host\n";
      }
    }
  }
  close( VIEWS );
}