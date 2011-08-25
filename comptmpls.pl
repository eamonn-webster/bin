use strict;

my $sourcesDir = $ARGV[0];
if ( $sourcesDir ) {
  chdir( $sourcesDir );
}

my $templateDir = "templates";

opendir( DIR, $templateDir ) or die "can't open directory [$templateDir]";

while ( defined( my $file = readdir(DIR) ) ) {
  if ( $file =~ /([^\\]+)\.tmpl$/ ) {
    my $stem = $1;
    my $output = "kDefault${stem}Template.inc";
    if ( !-e $output ) {
      print "$file to $output\n";

      my $cmd = "perl tmpltostring.pl templates/${stem}.tmpl $output";
      print "$cmd\n";
      system( $cmd );
    }
  }
}
closedir(DIR);

