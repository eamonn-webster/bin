use strict;

my $Ctool = "cleartool";

my $FileName = "u:\\topclass\\oracle\\topclass\\sources\\GroupSkillProfile.tmpl";

`$Ctool checkout -nc $FileName 2>&1`;

`$Ctool uncheckout -rm $FileName 2>&1`;

my $description = `$Ctool describe $FileName` ;

my $file    = "";
my $branch  = "";
my $version = "";
my $hasLabels = 0;

if ( $description =~ /version \"(.*)@@\\main\\?([A-Za-z0-9-_]*)\\([0-9]+)\"/ )
  {
    #print;
    $file    = $1;
    $branch  = $2;
    $version = $3;

    #print "file:    $file\n";
    #print "version: $version\n";
    #print "branch:  $branch\n";
  }
if ( $description =~ /Labels:/ )
  {
    $hasLabels = 1;
  }

if ( $version == 0 && $hasLabels == 0 )
  {
    #print "$Ctool rmbranch $FileName\@\@\\main\\$branch\n";
    `$Ctool rmbranch -force $FileName\@\@\\main\\$branch 2>&1`;
  }


