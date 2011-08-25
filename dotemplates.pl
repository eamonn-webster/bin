# process all templates


$some_dir = "U:\\topclass\\oracle\\topclass\\sources\\";

while (<*.tmpl>) {
    #print "$_\n";
    if ( /([a-zA-Z0-9]*)\.tmpl/ ) {
      #print "$1\n";
      `perl tmpltostring.pl $1.tmpl kDefault$1Template.inc`;
    }
}
