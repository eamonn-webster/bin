#
# File: get_country_codes.pl
# Author: eweb
# Copyright WBT Systems, 1995-2010
# Contents:
#
# Date:          Author:  Comments:
#  6th Oct 2010  eweb     #12632 Get ISO_3166 country or subdivision codes
#
use strict;

use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use Getopt::Std;

my $ua = new LWP::UserAgent;

my $url = "http://www.iso.org/iso/list-en1-semic-3.txt";

my $request = new HTTP::Request("GET", $url);
my $response = $ua->request($request);
my $content = $response->content();

my @lines = split( /[\r\n]+/, $content );

mkdir( "Scripts" );
mkdir( "Scripts/ORACLE" );
mkdir( "Scripts/MSSQL" );
mkdir( "Scripts/MSSQL/shopping_cart" );

my $Year = (localtime(time))[5]+1900;

my $verbose;
my $ora;
my $sql;

my %opts = ( C => undef(),
             S => undef(),
           );

# Was anything other than the defined option entered on the command line?
if ( !getopts("C:S:", \%opts) or @ARGV > 0 )
  {
    print STDERR "Unknown arg $ARGV[0]\n\n" if @ARGV > 0;
    Usage();
    exit;
  }

sub Usage() {
  print "Usage perl $0 options\n";
  print " -C [Y/N] get country codes (from iso)\n";
  print " -S [Y|alpha2] get state codes for all | give country (from wiki)\n";
}

sub fromIso() {
  my $file = "sc_country_init.sql";
  print "Scripts/ORACLE/$file\n";
  open( $ora, ">Scripts/ORACLE/$file" );
  print "Scripts/MSSQL/shopping_cart/$file\n";
  open( $sql, ">Scripts/MSSQL/shopping_cart/$file" );

  foreach ( @lines ) {
    if ( /([^;]+);([A-Z][A-Z])$/ ) {
      my $orig = $1;
      my $name = $orig;
      my $code = $2;
      # handle Saint A at the begining of Aland
      $name =~ s!\xc5!A!;
      $name =~ s/([\w']+)/\u\L$1/g;
      $name =~ s/\bAnd\b/and/g;
      $name =~ s/\bOf\b/of/g;
      my @parts = split( /, /, $name );
      if ( $#parts eq 1 ) {
        if ( $parts[1] =~ /Republic/ ) {
          $name = $parts[1] . ' ' . $parts[0];
        }
        elsif ( $parts[1] =~ /States? of/ ) {
          $name = $parts[1] . ' ' . $parts[0];
        }
        else {
          #print "$name\n";Å
        }
      }
      $name =~ s/Holy See \(Vatican City State\)/Vatican City/;
      $name =~ s/CÔTe D'Ivoire/Côte d'Ivoire/i;
      #print "$code $name\n";

      $name =~ s!'!''!g;
      #if ( $code eq "AX" ) {
      #  print "$code $name\n";
      #}
      # oracle
      print $ora "  INSERT INTO WCountry( WCountry_ID, WLongName, WShortName ) SELECT oInsert.getUniqueId(),'$name','$code' FROM DUAL WHERE NOT EXISTS ( SELECT NULL FROM WCountry WHERE WShortName = '$code' );\n";

      # sql server
      print $sql "  exec getUniqueID \@id OUTPUT;\n";
      print $sql "  INSERT INTO WCountry( WCountry_ID, WLongName, WShortName ) SELECT \@id, N'$name', N'$code' WHERE NOT EXISTS ( SELECT NULL FROM WCountry WHERE WShortName = N'$code' );\n";
    }
  }
  filefooter( $ora, "ora" );
  filefooter( $sql, "sql" );

  close( $ora );
  close( $sql );
}

sub fileheader($$$) {
  my ($out, $which, $file) = @_;
  print $out "--\n";
  print $out "-- File: $file\n";
  print $out "-- Author: deesy\n";
  print $out "-- Copyright WBT Systems, 1995-$Year.\n";
  print $out "-- Content: TopClass Shopping Cart Tables;\n";
  print $out "--\n";
  if ( $which eq "ora" ) {
    print $out "COLUMN DUMMY_TITLE NOPRINT\n";
    print $out "\n";
    print $out "TTITLE LEFT COL 3 '-- ============================================================ --' SKIP 1 -\n";
    print $out "       LEFT COL 3 '-- File: $file                                    --' SKIP 1 -\n";
    print $out "       LEFT COL 3 '-- ============================================================ --' SKIP 2\n";
    print $out "\n";
    print $out "SELECT NULL AS DUMMY_TITLE\n";
    print $out "FROM DUAL\n";
    print $out "/\n";
    print $out "\n";
    print $out "TTITLE OFF\n";
  }
  else {
    print $out "SET NOCOUNT ON\n";
    print $out "GO\n";
    print $out "\n";
    print $out "PRINT N'============================';\n";
    print $out "PRINT N'File: $file   ';\n";
    print $out "PRINT N'============================';\n";
    print $out "PRINT N'';\n";
    print $out "GO\n";
  }
  print $out "\n";
  print $out "BEGIN\n";
  print $out "\n";

  if ( $which ne "ora" ) {
    print $out "  DECLARE\n";
    print $out "    \@id INTEGER;\n";
  }
}

sub filefooter($$) {
  my ($out, $which) = @_;
  print $out "\n";
  if ( $which eq "ora" ) {
    print $out "END;\n";
    print $out "/\n";
    print $out "COMMIT\n";
    print $out "/\n";
  }
  else {
    print $out "END;\n";
    print $out "GO\n";
  }
  print $out "\n";
}

sub fromWiki() {
  my $url = "http://en.wikipedia.org/wiki/ISO_3166-1";
  my $request = new HTTP::Request("GET", $url);
  my $response = $ua->request($request);
  my $content = $response->content();
  my @lines = split( /[\r\n]+/, $content );
  my $show;
  my $name;
  my $alpha2;
  my $alpha3;
  my $states;
  foreach ( @lines ) {
    if ( /Officially assigned code elements/ ) {
      $show = 1;
    }
    if ( /<tr>/ ) {
      $name = undef;
      $alpha2 = undef;
      $alpha3 = undef;
      $states = undef;
    }
    elsif ( /<\/tr>/ ) {
      if ( $name and $alpha2 and $alpha3 ) {
        print "'$name', '$alpha2', '$alpha3', '$states'\n" if ( $verbose );
      }
    }
    elsif ( /class="flagicon"/ ) {
      #print "found flag line\n";
      if ( /<span class="flagicon"[^>]*>.+<\/span><a href[^>]+>([^<]+)<\/a>(<\/span>)?<\/td>/ ) {
        #print "matched flag line\n";
        $name = $1;
      }
      else {
        print "didn't match flag line:\n$_\n";
      }
    }
    elsif ( /<td><a href="[^"]+" title="ISO 3166-1 alpha-2"><tt>([A-Z][A-Z])<\/tt><\/a><\/td>/ ) { #"
      #print "found alpha2 line\n";
      $alpha2 = $1;
    }
    elsif ( /<td><tt>([A-Z][A-Z][A-Z])<\/tt><\/td>/ and !$alpha3 ) {
      #print "found alpha3 line\n";
      $alpha3 = $1;
    }
    elsif ( /<td><a href="(\/wiki\/ISO_3166-2:([A-Z][A-Z]))" title="ISO 3166-2:([A-Z][A-Z])">ISO 3166-2:([A-Z][A-Z])<\/a><\/td>/ ) {
      if ( $2 eq $alpha2 and $3 eq $alpha2 and $4 eq $alpha2 ) {
        $states = $1;
        #if ( $alpha2 eq "IE" ) {
          getStatesFromWiki( $alpha2, $name );
        #}
      }
    }
    elsif ( $name and $alpha2 and $alpha3 ) {
      #print "$_\n";
    }
  }
}

sub getStatesFromWiki($$) {
  my ($alpha2, $country) = @_;
  my $url = "http://en.wikipedia.org/wiki/ISO_3166-2:$alpha2";
  my $request = new HTTP::Request("GET", $url);
  my $response = $ua->request($request);
  my $content = $response->content();
  my @lines = split( /[\r\n]+/, $content );
  my $show;
  my $name;
  my $code;
  $show = 1;
  print $ora "  -- $country $url\n";
  print $sql "  -- $country $url\n";
  foreach ( @lines ) {
#<tr>
#<td><tt>IE-CW</tt></td>
#<td><a href="/wiki/County_Carlow" title="County Carlow">Carlow</a></td>
#<td>Ceatharlach</td>
#<td><a href="/wiki/Leinster" title="Leinster"><tt>L</tt></a></td>
#</tr>
    if ( /<tr/ ) {
      $name = undef;
      $code = undef;
    }
    elsif ( /<\/tr>/ ) {
      if ( $name and $code ) {
        print "'$alpha2', '$name', '$code'\n" if ( $verbose );

        my $sqlname = $name;
        my $oraname = $name;
        $sqlname =~ s!'!''!g;
        $oraname =~ s!'!''!g;

        # oracle
        print $ora "  INSERT INTO WState( WState_ID, WCountry_ID, WLongName, WShortName ) SELECT oInsert.getUniqueId(), WCountry_ID, '$oraname', '$code' FROM WCountry WHERE WShortName = '$alpha2' AND NOT EXISTS ( SELECT NULL FROM WState WHERE WShortName = '$code' );\n";

        # sql server
        print $sql "  exec getUniqueID \@id OUTPUT;\n";
        print $sql "  INSERT INTO WState( WState_ID, WCountry_ID, WLongName, WShortName ) SELECT \@id, WCountry_ID, N'$sqlname', N'$code' FROM WCountry WHERE WShortName = '$alpha2' AND NOT EXISTS ( SELECT NULL FROM WState WHERE WShortName = N'$code' );\n";
      }
    }
    elsif ( /<td><tt>$alpha2-([A-Z0-9]+)<\/tt>/ ) {
      $code = $1;
    }
    elsif ( /<td><a href=[^>]+>([^<]+)<\/a><\/td>/ && !$name ) {
      $name = $1;
    }
    elsif ( /<td><a href=[^>]+>([^<]+)<\/a><\/td>/ ) {
      print "Second name? $1\n";
    }
    elsif ( /<td><a href=[^>]+>([^<]+)<\/a> \[.+\]<\/td>/ && !$name ) {
      $name = $1;
    }
    elsif ( /<td><a href=[^>]+>([^<]+)<\/a> \[.+\]<\/td>/ ) {
      print "Second name? $1\n";
    }
    elsif ( /<td><span class="flagicon"[^>]*>.+<\/span><a href=[^>]+>([^<]+)<\/a><\/td>/ && !$name ) {
      $name = $1;
    }
    elsif ( /<td><span class="flagicon"[^>]*>.+<\/span><a href=[^>]+>([^<]+)<\/a><\/td>/ ) {
      print "Second name? $1\n";
    }
    elsif ( /<td>([^<]+)<\/td>/ ) {
      # local name?
    }
    elsif ( /<td><a href=[^>]+><tt>([A-Z0-9]+)<\/tt><\/a><\/td>/ ) {
      # province code?
      #print "Second province code? $1\n";
    }
    elsif ( /<td/ ) {
      if ( /<td><\/td>/ ) {
      }
      elsif ( /<td class=\"navbox/ ) {
      }
      elsif ( /<td><span class=\"flag/ ) {
        print "$alpha2: [$_]\n";
      }
      elsif ( /<td style=\"/ ) {
      }
      elsif ( /<td id=\"/ ) {
      }
      elsif ( /<td><span style=\"/ ) {
      }
      elsif ( /^<td>$/ ) {
      }
      elsif ( /Subdivisions added:/ ) {
      }
      elsif ( /class="mw-redirect"/ ) {
      }
      else {
        print "$alpha2: [$_]\n";
      }
    }
  }
}

my $Countries = uc $opts{C};
my $States = uc $opts{S};
if ( $Countries eq "Y" ) {
  fromIso();
}

if ( $States eq "Y" ) {
  my $file = "sc_state_init.sql";
  print "Scripts/ORACLE/$file\n";
  open( $ora, ">Scripts/ORACLE/$file" );
  print "Scripts/MSSQL/shopping_cart/$file\n";
  open( $sql, ">Scripts/MSSQL/shopping_cart/$file" );
  fileheader( $ora, "ora", $file );
  fileheader( $sql, "sql", $file );
  fromWiki();
  filefooter( $ora, "ora" );
  filefooter( $sql, "sql" );

  close( $ora );
  close( $sql );
}
elsif ( $States ) {
  my $file = "sc_state_init_" . lc $States . ".sql";
  print "Scripts/ORACLE/$file\n";
  open( $ora, ">Scripts/ORACLE/$file" );
  print "Scripts/MSSQL/shopping_cart/$file\n";
  open( $sql, ">Scripts/MSSQL/shopping_cart/$file" );
  fileheader( $ora, "ora", $file );
  fileheader( $sql, "sql", $file );

  getStatesFromWiki( $States, $States );

  filefooter( $ora, "ora" );
  filefooter( $sql, "sql" );

  close( $ora );
  close( $sql );
}

