use strict;

my $sqlFile = $ARGV[0];
my $outDir = $ARGV[1];

if ( $outDir eq "" ) {
  $outDir = ".";
}

if ( ! -d $outDir ) {
  mkdir( $outDir );
}

if ( open( SQLIN, $sqlFile ) ) {
  my $sqlOut;
  my $table;
  while ( <SQLIN> ) {
    if ( /^--/ ) {
      next;
    }
    if ( /create table ([a-z0-9_]+)/i ) {
      my $newTable = $1;
      #print "Table: $table\n";
      if ( $sqlOut ) {
        fileFooter( $sqlOut, $table );
        close( $sqlOut );
        $sqlOut = undef();
      }
      $table = $newTable;
      my $outFile = "$outDir\\$table.sql";

      if ( !open( $sqlOut, ">$outFile" ) ) {
        print "Failed to open $outFile\n";
      }
      fileHeader( $sqlOut, $table );
    }
    if ( $sqlOut ) {
      print $sqlOut $_;
    }
  }
  close(SQLIN);
  if ( $sqlOut ) {
    fileFooter( $sqlOut, $table );
    close( $sqlOut );
    $sqlOut = undef();
  }
}

sub fileHeader($$) {
  my ($out, $table) = @_;

  print $out "--\n";
  print $out "--  File: $table.sql\n";
  print $out "--  This file was extracted by a perl program.\n";
  print $out "--  Copyright WBT Systems, 1995-2009\n";
  print $out "--\n";

  print $out "COLUMN DUMMY_TITLE NOPRINT\n";
  print $out "TTITLE LEFT COL 3 '-- ============================================================ --' SKIP 1 -\n";
  print $out "       LEFT COL 3 '-- File: $table.sql                                           --' SKIP 1 -\n";
  print $out "       LEFT COL 3 '-- ============================================================ --' SKIP 2\n";
  print $out "SELECT NULL AS DUMMY_TITLE\n";
  print $out "FROM DUAL\n";
  print $out "/\n";
  print $out "TTITLE OFF\n";
  print $out "\n";
}

sub fileFooter($$) {
  my ($out, $table) = @_;
}
