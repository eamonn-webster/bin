use strict;

my $label = $ARGV[0];

my @vobs = qw/topclass authoring utils 3rdparty esd/;

system( "cleartool catcs > c:\\temp\\configspec.old" );

system( "echo element * $label > c:\\temp\\configspec.new" );
system( "echo element * /main/LATEST >> c:\\temp\\configspec.new" );

system( "cleartool setcs c:\\temp\\configspec.new" );

#@vobs = qw/utils esd/;

foreach ( @vobs ) {
  my $cmd = "cleartool find \"\\$_\\lost+found\" -version lbtype($label) -exec \"cleartool rmlabel $label \\\"%clearcase_pn%\\\"\"";
  print "$cmd\n";
  system( $cmd );
}

system( "cleartool setcs c:\\temp\\configspec.old" );
