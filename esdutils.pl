#
# esdutils.pl
#
#

use strict;

#need to know the root directories e.g.
#\esd, \topclass\java

#production view: danderson_elt_742_prod

# inputs customer version

use Getopt::Std;

my %opts = ( c => undef(),
             v => undef(),
             p => undef(),
             w => undef(),
             b => undef(),
             O => undef(),
             l0 => undef(),
             l1 => undef(),
           );

# Was anything other than the defined option entered on the command line?
if ( !getopts("c:v:p:w:b:O:l0:l1", \%opts) )
  {
    print STDERR "Unknown args @ARGV\n";
    #Usage();
    exit;
  }

my $customer   = $opts{c};
my $tcver      = $opts{v};
my $prod_drive = $opts{p};
my $work_drive = $opts{w};
my $build      = $opts{b};
my $old_branch = $opts{O};
my $ver0       = $opts{l0};
my $ver1       = $opts{l1};

my $prod_branch;
my $work_branch;
my $prod_view;
my $work_view;

if ( $customer ne "" && $tcver ne "" )
  {
    $prod_branch = lc "${customer}_${tcver}_prod";
    $work_branch = lc "${customer}_${tcver}_work";
    $prod_view = lc $ENV{USERNAME} . "_" . $prod_branch;
    $work_view = lc $ENV{USERNAME} . "_" . $work_branch;
  }


my $labelTopClass = ""; # could be "all" or "java"

my $cmd;

#my @vobs = qw/esd topclass/;
my @vobs = qw/esd/;

sub runcmd( $ )
  {
    my ($cmd) = @_;
    print "$cmd\n";
    if ( open( CMD, "$cmd 2>&1 |" ) )
      {
        while ( <CMD> )
          {
            print;
          }
        close( CMD );
      }
  }

sub setup_prod()
  {
    if ( $prod_branch eq "" or $tcver eq "" or $build eq "" )
      {
        die "setup_prod: must specify customer, tcver and build\n";
      }
    for my $vob ( @vobs )
      {
        $cmd = "cleartool mkbrtype -nc $prod_branch\\@\\$vob";
        runcmd( $cmd );
      }

    runcmd( "perl mkview.pl $prod_branch $prod_drive" );

    my $cs = "c:\\temp\\prod.cs";

    if ( open( CS, ">$cs" ) )
      {
        print CS "element * CHECKEDOUT\n";
        print CS "element /utils/AutoDevBuild/... /main/LATEST\n";
        print CS "element * /main/.../$prod_branch/LATEST\n";
        print CS "element * TC_${tcver}_BUILD_${build} -mkbranch $prod_branch\n";
        print CS "element * /main/LATEST -mkbranch $prod_branch\n";
      }

    runcmd( "cleartool setcs -tag $prod_view $cs" );
  }

sub setWorkConfigSpec()
  {
    if ( $prod_branch eq "" or $work_branch eq "" or $tcver eq "" or $build eq "" )
      {
        die "setWorkConfigSpec: must specify customer, tcver and build\n";
      }

    my $cs = "c:\\temp\\work.cs";

    if ( open( CS, ">$cs" ) )
      {
        print CS "element * CHECKEDOUT\n";
        print CS "element /utils/AutoDevBuild/... /main/LATEST\n";
        print CS "element * /main/.../$prod_branch/$work_branch/LATEST\n";
        print CS "element * /main/.../$prod_branch/LATEST -mkbranch $work_branch\n";
        print CS "element * TC_${tcver}_BUILD_${build} -mkbranch $prod_branch\n";
        print CS "element * /main/LATEST -mkbranch $prod_branch\n";
      }

    runcmd( "cleartool setcs -tag $work_view $cs" );
  }

sub setup_work()
  {
    if ( $prod_branch eq "" or $work_branch eq "" or $tcver eq "" or $build eq "" )
      {
        die "setup_work: must specify customer, tcver and build\n";
      }
    for my $vob ( @vobs )
      {
        $cmd = "cleartool mkbrtype -nc $work_branch\\@\\$vob";
        runcmd( $cmd );
      }

    runcmd( "perl mkview.pl $work_branch $work_drive" );

    setWorkConfigSpec();
  }


sub labelStuff( $$$ )
  {
    my ($view, $type, $ver) = @_;
    if ( $customer eq "" or $tcver eq "" or $type eq "" or $ver eq "" )
      {
        die "labelStuff not enough info to construct label name\n";
      }
    my $label = uc "${customer}_${tcver}_${type}_${ver}";

    runcmd( "cleartool mklbtype -nc $label\\@\\esd\n" );
    runcmd( "cleartool mklabel -recurse $label \\\\view\$view\\esd\n" );

    if ( $labelTopClass ne "" )
      {
        runcmd( "cleartool mklbtype -nc ${label}\@\\topclass" );

        if ( $labelTopClass eq "all" )
          {
            runcmd( "cleartool mklabel -recurse ${label} \\\\view\\$view\\topclass\n" );
          }
        elsif ( $labelTopClass eq "java" )
          {
            runcmd( "cleartool mklabel ${label} \\\\view\\$view\\topclass\n" );
            runcmd( "cleartool mklabel -recurse ${label} \\\\view\\$view\\topclass\\java\n" );
          }
      }
  }


sub startNewWork()
  {
    #Merge existing stuff into new branches.

    runcmd( "clearmrgman /branch $old_branch /toview $work_view /namelist \esd " );


    # Apply a label to act as a baseline

    labelStuff( $work_view, "WORK", "00" );
  }

sub upgradeCustomer()
  {
    #upgrade customer to build 36

    #edit work view config spec change label TC_742_BUILD_034 to TC_742_BUILD_036

    setWorkConfigSpec();


    #merge build 36 changes into elt work branch only happens if file
    #changed between builds 34 and 36 and has been branched for elt

    my $namelist = "\\esd";
    if ( $labelTopClass ne "" )
      {
        $namelist = "\\esd \\topclass";
      }
    runcmd( "clearmrgman /label TC_${tcver}_BUILD_${build} /toview %{work_view} /namelist $namelist" );


    #create another baseline...

    labelStuff( $work_view, "WORK", "01" );
  }



#Report on differences

sub diffsBetweenLabels()
  {
    my $label0 = uc "${customer}_${tcver}_WORK_${ver0}";
    my $label1 = uc "${customer}_${tcver}_WORK_${ver1}";

    runcmd( "perl \\utils\\AutoDevBuild\\ccrep.pl -E Y -c $label1 -p $label0 -d $work_drive -o \\\\elm\\esd\\Projects\\ClearcaseReports" );
  }

# prepare to release to customer topclass merge from work to prod

sub mergeWork2Prod()
  {
    my $namelist = "\\esd";
    if ( $labelTopClass ne "" )
      {
        $namelist = "\\esd \\topclass";
      }

    runcmd( "clearmrgman /branch $work_branch /toview $prod_view /namelist $namelist" );


    labelStuff( $prod_view, "REL", "01" );
  }


#Label the release with a _REL_ label on the prod branch selected by the prod view
# Need to determine the next release...


