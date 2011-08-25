#******************************************************************************
#
#  File: gennew.pl
#  Author: eweb
#  Copyright WBT Systems, 2005-2006
#  Contents: generates new .dat files and .lang files from the usenglish files.
#
#******************************************************************************
#
# Date:          Author:  Comments:
#  7th Nov 2006  eweb     Generate unicode files.
#

# generate the .dat files

$number = $ARGV[0];
$code   = $ARGV[1];
$ident  = $ARGV[2];
$name   = $ARGV[3];
$langs  = $ARGV[4];

if ( $number eq "" or $code eq "" or $ident eq "" )
  {
    print "perl $0 number code ident name\n";
    print "e.g. perl $0 2 uk ukenglish \"UK English\"\n";
    exit;
  }
if ( $name eq "" )
  {
    $name   = $ident;
  }

opendir( DIR, "." ) or die "can't open directory";
while ( defined( $file = readdir(DIR) ) ) {
  if ( $file =~ /langrps\.dat$/ ) {
    #print "$file\n";
  }
  elsif ( $file =~ /_..\.dat$/ ) {
    #print "$file\n";
  }
  elsif ( $file =~ /_abc\.dat$/ ) {
    #print "$file\n";
  }
  elsif ( $file =~ /(.*)\.dat$/ ) {
    print "$file to $1_$code.dat\n";
    $INPUT = $file;
    open INPUT or die;
    $OUTPUT = ">$1_$code.dat";
    open OUTPUT or die;
    binmode OUTPUT, ":bytes";
    print OUTPUT "\357\273\277";
    binmode OUTPUT, ":utf8";
    while ( $_ = <INPUT> )
      {
        if ( /^$/ )
          {
            next;
          }
        #;Filename=cpi_SyncServer_ukenglish.lang
        elsif ( /^;Filename=(.*)_usenglish.lang/ )
          {
            print OUTPUT ";Filename=$1_${ident}.lang\n";
          }
        elsif ( /^;Language=/ )
          {
            print OUTPUT ";Language=${ident}\n";
          }
        elsif ( /^;LanguageNumber=/ )
          {
            print OUTPUT ";LanguageNumber=${number}\n";
          }
        elsif ( /^;Comment=/ )
          {
            print OUTPUT ";Comment=${name}\n";
          }
        elsif ( /^;/ )
          {
            next;
          }
        elsif ( /\"([^\"]*)\"\W+([0-9]*)\W+(\".+)$/ )
          {
            $funcname = $1;
            $strnumber = $2;
            $strvalue = $3;
            print OUTPUT "\"$funcname\" $strnumber $strvalue\n";
          }
      }
    close( $INPUT );
    close( $OUTPUT );
  }
}
closedir(DIR);

if ( lc $langs eq "y" )
  {
    # generate the .lang files
    opendir( DIR, "." ) or die "can't open directory";
    while ( defined( $file = readdir(DIR) ) )
      {
        if ( $file =~ /_$code\.dat$/ )
          {
            #print "[$file]\n";
            $Cmd = "langutils -u $file";
            #print "Command: [$Cmd]\n";
            system( $Cmd );
          }
      }
    closedir(DIR);
  }

