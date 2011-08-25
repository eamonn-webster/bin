#******************************************************************************
#
#  File: esdcopy.pl
#  Author: eweb - eweb@wbtsystems.com
#  Copyright WBT Systems, 2005-2006
#  Contents: Copy customisation files to the esd vob...
#
#******************************************************************************
#
# Date:          Author:  Comments:
#  9th Jun 2005  eweb     Created
# 29th Jun 2006  eweb     Got it working (on frodo) for 7.4.0.108
# 26th Sep 2006  eweb     Re org of directories.
# 27th Sep 2006  eweb     View based rather than drive based.
# 25th Oct 2006  eweb     Use strict. Don't checkin by default, Copy tcc files.

# Issues as of 9th Jun 2005
# - More options things are hard coded
# - Won't handle files that get renamed...
# - file types might go astray...
# - doesn't recurse
# - more error checking.
# - need to log everything
# - auto generate the config specs
# - repackaging...
# - what to copy...
# - how far back...
# - Branching of Directories needs to be checked...
# - unco if identical with previous.

# For a given file
# Does it exist in the destination folder?
# Is it different?
# Is it a clearcase element?
# does it need to be branched?

# if destination file differs from source file
#    or
#    destination file not an element

# if destination file not an element
#   mkelem
# []

# if branching required
#   do for each branch
#     create brtype
#     create branch
#   od
# fi

# check out
# copy
# check in

use strict;
use DirHandle;

my $cctool1 = "cleartool"; # for info gathering
my $cctool2 = "cleartool"; # for commands that DO something
my $cctool3 = "cleartool"; # for commands that check in
my $cctool4 = "cleartool"; # for commands that create labels
#my $Major;
#my $Minor;
#my $Point;
#my $Build;

my $UseClearCase = "Y";
my $CheckIn      = "N";

#my $configspecs = "c:\\Configspecs";
#my $devview = "bob_view";
my $esdview; # = "bob_esd";
#my $devdrive = "y:";
my $esddrive; # = "u:";

my $src;
my $label;

#my $cmd;

use Getopt::Std;

sub main()
{

my %opts = ( d => undef(),
             e => undef(),
             s => undef(),
             b => undef(),
             m => undef(),
             n => undef(),
             p => undef(),
             l => undef(),
             U => undef(),
             I => undef() );


  # Was anything other than the defined option entered on the command line?
  if ( !getopts("d:s:e:b:m:n:p:U:I:l:", \%opts) or @ARGV > 0 )
    {
      print "Unknown args @ARGV\n";
      #Usage();
      exit;
    }

      $label = uc $opts{l};
      $src = $opts{s};

#      $Major = $opts{m};
#      $Minor = $opts{n};
#      $Point = $opts{p};
#      $Build = $opts{b};

#  if ( !defined( $Major ) )
#    {
#      print "No major version given\n";
#      exit;
#    }
#  if ( !defined( $Minor ) )
#    {
#      print "No minor version given\n";
#      exit;
#    }
#  if ( !defined( $Point ) )
#    {
#      print "No point version given\n";
#      exit;
#    }
#  if ( !defined( $Build ) )
#    {
#      print "No build number given\n";
#      exit;
#    }

#  if ( defined( $opts{d} ) )
#    {
#      $devview = $opts{d};
#      $devdrive = "\\\\view\\$devview";
#    }
  if ( defined( $opts{e} ) )
    {
      $esdview = $opts{e};
      $esddrive = "\\\\view\\$esdview";
    }
  if ( defined( $opts{U} ) )
    {
      $UseClearCase = $opts{U};
    }
  if ( defined( $opts{I} ) )
    {
      $CheckIn = $opts{I};
    }
  #if ( $src eq "" or $label eq "" or $esdview eq "" )
  #  {
  #    die "Must specify -s src -l label -e view\n";
  #  }
  if ( $src eq "" or $esdview eq "" )
    {
      die "Must specify -s src -e view\n";
    }

if ( $UseClearCase ne "Y" )
  {
    $cctool2 = "echo";
    $cctool3 = "echo";
  }
if ( $CheckIn ne "Y" )
  {
    $cctool3 = "echo";
  }

#$label = "TC_$Major$Minor$Point" . "_BUILD_$Build";

#my $VersionStr = $Major . "." . $Minor . "." . $Point . " build " . $Build;

# set up config spec to select a given label

my $cmd;
#my $cmd = "$cctool1 catcs -tag $devview > savecs";

#execute( $cmd );

#my $esdCS =  "$configspecs\\tc$Major$Minor$Point" . "b$Build" . ".cs";

#if ( !open( CS, $esdCS ) )
#  {
#    print "failed to open esd config spec [$esdCS]\n";
#  }
#elsif ( !open( CS, ">tempcs" ) )
#  {
#    print "failed to open tempcs for writing\n";
#  }
#else
#  {
#    print CS "element * $label\n";
#    close(CS);
#
#    $cmd = "$cctool1 setcs -tag $devview tempcs";
#    execute( $cmd );
#
#    $cmd = "$cctool1 setcs -tag $esdview $configspecs\\tc$Major$Minor$Point" . "b$Build" . ".cs";
#    execute( $cmd );

    # copy from this view to the esd vob
    # but only if changed
    # check out if necessary

    # documentation
    #copydir( "$devdrive\\topclass\\oracle\\install\\distribution\\nonwebable", "$esddrive\\esd\\nonwebable\\documentation", 0, "7" );

    # non webable
#    copydir( "$devdrive\\topclass\\oracle\\install\\distribution\\nonwebable\\dat", "$esddrive\\esd\\nonwebable\\dat",       0, "formdef.*\.xml" );
#    copydir( "$devdrive\\topclass\\oracle\\topclass\\languages",                    "$esddrive\\esd\\nonwebable\\languages", 0, "\.dat\$" );
#    copydir( "$devdrive\\topclass\\oracle\\topclass\\sources",                      "$esddrive\\esd\\templates",             0, "\.tmpl\$" );
    copydir( "$src",                      "$esddrive\\esd\\templates",             0, "\.tmpl\$" );

    # webable
#    copydir( "$devdrive\\topclass\\oracle\\install\\distribution\\webable",        "$esddrive\\esd\\webable",        0, "\.html\$ \.js\$ \.css\$ \.asp\$ \.gif\$" );
#    copydir( "$devdrive\\topclass\\oracle\\install\\distribution\\webable\\icons", "$esddrive\\esd\\webable\\icons", 1, "\.html\$ \.js\$ \.css\$ \.asp\$ \.gif\$" );
#    copydir( "$devdrive\\topclass\\oracle\\install\\distribution\\webable\\cal",   "$esddrive\\esd\\webable\\cal",   0, "\.html\$ \.js\$ \.css\$ \.asp\$ \.gif\$" );

    # tcc
#    copydir( "$devdrive\\topclass\\java\\cnr\\web",                       "$esddrive\\esd\\tcc\\cnr", 1, "\.jsp\$ \.html\$ \.js\$ \.css\$ \.tld\$ \.gif\$ \.properties\$" );
#    copydir( "$devdrive\\topclass\\java\\cnr\\src\\com\\wbtsystems\\cnr", "$esddrive\\esd\\tcc\\cnr\\WEB-INF\\classes\\com\\wbtsystems\\cnr", 0, "\.properties\$" );
#    copydir( "$devdrive\\topclass\\java\\common\\com\\wbtsystems\\sql",   "$esddrive\\esd\\tcc\\cnr\\WEB-INF\\classes\\com\\wbtsystems\\sql", 0, "sql\.xml\$" );

    # add to clear case if not there
    # remove if it has disappeared
    # check everything in

    #restore config spec
#    $cmd = "$cctool1 setcs -tag $devview savecs";
#    execute( $cmd );

    if ( $label ne "" )
      {
#    # make label
#    $cmd = "$cctool4 mklbtype -comment \"$label\" $label@\\esd";
       $cmd = "$cctool4 mklbtype -nc $label@\\esd";
       execute( $cmd );
#    # apply label
#    $cmd = "$cctool4 mklabel -replace -recurse $label $esddrive\\esd\\webable";
#    execute( $cmd );
#    $cmd = "$cctool4 mklabel -replace -recurse $label $esddrive\\esd\\nonwebable";
#    execute( $cmd );
       $cmd = "$cctool4 mklabel -replace -recurse $label $esddrive\\esd\\templates";
       execute( $cmd );
#    $cmd = "$cctool4 mklabel -replace -recurse $label $esddrive\\esd\\tcc";
#    execute( $cmd );
    }
}


sub execute($)
  {
    my ($aCmd) = @_;
    print "$aCmd\n";
    system( $aCmd );
#    my $output = `$aCmd`;
#
#    # put in <br>s
#    $_ = $output;
#    s/\n/<br>\n/g;
#    $output = $_;
#
#    print $output;
  }

sub FilesDiffer($$)
  {
    my ($src, $dst) = @_;

    # do they differ?
    my $cmd = "fc $src $dst 2>&1";
    my $fcinfo = `$cmd`;
    if ( $fcinfo =~ /\nFC: no differences encountered\n/ )
      {
        return 0;
      }
    return 1;
  }

sub NeedToMkElem( $ )
  {
    my ($f) = @_;
    if ( -f $f )
      {
        my $cmd = "$cctool1 desc -short $f";
        my $ccinfo = `$cmd`;
        if ( $ccinfo =~ /@@/ )
          {
            return 0;
          }
      }
    return 1;
  }

sub NeedToMkDir( $ )
  {
    my ($d) = @_;
    if ( -d $d )
      {
        my $cmd = "$cctool1 desc -short $d";
        my $ccinfo = `$cmd`;
        if ( $ccinfo =~ /@@/ )
          {
            return 0;
          }
      }
    return 1;
  }

sub copydir($$$$)
  {
    #for each file in src compare it with dst
    #if it has changed then copy it...
    my ($src, $dst, $recurse, $patterns) = @_;

    print "copyDir: $src $dst $recurse $patterns\n";

    my $added = 0;

    if ( NeedToMkDir($dst) == 1 )
      {
        my $cmd = "$cctool2 mkelem -mkpath -nco -nc -eltype directory $dst"; # create the main\0 version of the directory
        if ( $UseClearCase eq "N" )
          {
            system( $cmd );
            mkdir($dst);
          }
        else
          {
            my $ccinfo = `$cmd`;
            print "mkelem: $ccinfo";
          }
      }
    else if ( 1 eq 0 )
      {
        # determine how branched it is
        my $cmd = "$cctool1 desc -short $src";
        my $ccinfo = `$cmd`;
        $ccinfo =~ /\\([^\\]+)@@\\(.*)\\[0-9]+$/;
        my $srcbranch = $2;

        $cmd = "$cctool1 desc -short $dst";
        $ccinfo = `$cmd`;
        $ccinfo =~ /\\([^\\]+)@@\\(.*)\\[0-9]+$/;
        my $dstbranch = $2;

        if ( $srcbranch ne $dstbranch )
          {
            my @branches = split( /\\/, $srcbranch );
            #print "branches: @branches\n";

            for ( my $i = 1; $i < @branches; $i++ )
              {
                # check if the branch type exists...
                $cmd = "$cctool1 desc -short brtype:$branches[$i]@\\esd";
                $ccinfo = `$cmd 2>&1`;
                print "desc: $ccinfo";

                # if it doesn't
                if ( $ccinfo =~ /cleartool: Error: Branch type not found:/ )
                  {
                    # then create it
                    $cmd = "$cctool2 mkbrtype -nc $branches[$i]@\\esd"; # now branch
                    $ccinfo = `$cmd 2>&1`;
                    print "mkbrtype: $ccinfo";
                  }
                $cmd = "$cctool2 mkbranch -nc -nco $branches[$i] $dst"; # now branch but don't check out
                $ccinfo = `$cmd 2>&1`;
                print "mkbranch: $ccinfo";
              }
          }
      }

    my $d = new DirHandle $src;

    if (defined $d)
      {
        my $f;
        while ( defined($f = $d->read))
          {
            if ( $f eq "." || $f eq ".." )
              {
              }
            # is it a file?
            elsif ( -d "$src\\$f" )
              {
                if ( $recurse == 1 )
                  {
                    copydir("$src\\$f", "$dst\\$f", $recurse, $patterns);
                  }
              }
            # is it a file?
            elsif ( -f "$src\\$f" )
              {
                my $matched = 0;
                # does it match any of the patterns?
                if ( $patterns eq "" )
                  {
                    $matched = 1;
                  }
                else
                  {
                    my @pats = split( / /, $patterns );
                    for ( my $j = 0; $j < @pats; $j++ )
                      {
                        # formdef*.xml
                        # *7*
                        # *.gif
                        my $pat = $pats[$j];
                        #print "patters $j: $pat\n";
                        if ( $f =~ /$pat/ )
                          {
                            #print "$f matches\n";
                            $matched = 1;
                          }
                        else
                          {
                            #print "$f doesn't match $pat\n";
                            #print "$f isn't a xml file\n";
                          }
                      }
                    if ( $matched == 0 )
                      {
                        #print "$f not matched\n";
                      }
                  }
                if ( $matched == 1 )
                  {
                    my $cmd = "$cctool1 desc -short $src\\$f";
                    my $ccinfo = `$cmd`;
                    $ccinfo =~ /\\([^\\]+)@@\\(.*)\\[0-9]+$/;
                    my $branch = $2;
                    #print "$1 on $2\n";
                    my $differs = 0;
                    if ( NeedToMkElem( "$dst\\$f" ) == 1 )
                      {
                        $differs = 1;
                        $cmd = "$cctool2 mkelem -mkpath -nco -nc $dst\\$f"; # just create the main\0 version...
                        $ccinfo = `$cmd`;
                        print "mkelem: $ccinfo";
                        $added = 1;
                      }
                    elsif ( FilesDiffer( "$src\\$f", "$dst\\$f" ) == 1 )
                      {
                        $differs = 1;
                      }

                    if ( $differs == 1 )
                      {
                        #print "$f on $branch\n";
                        # is a versioned object
                        #print "$f exists but isn't a clearcase element\n";

                        my @branches = split( /\\/, $branch );
                        #print "branches: @branches\n";

                        for ( my $i = 1; $i < @branches; $i++ )
                          {
                            # check if the branch type exists...
                            $cmd = "$cctool1 desc -short brtype:$branches[$i]@\\esd";
                            $ccinfo = `$cmd 2>&1`;
                            print "desc: $ccinfo";

                            # if it doesn't
                            if ( $ccinfo =~ /cleartool: Error: Branch type not found:/ )
                              {
                                # then create it
                                $cmd = "$cctool2 mkbrtype -nc $branches[$i]@\\esd"; # now branch
                                $ccinfo = `$cmd 2>&1`;
                                print "mkbrtype: $ccinfo";
                              }
                            $cmd = "$cctool2 mkbranch -nc -nco $branches[$i] $dst\\$f"; # now branch but don't check out.
                            $ccinfo = `$cmd 2>&1`;
                            print "mkbranch: $ccinfo";
                          }

                        $cmd = "$cctool2 co -c \"Copy $label\" $dst\\$f"; #check it out
                        $ccinfo = `$cmd 2>&1`;
                        print "ci: $ccinfo";

                        $cmd = "copy /y $src\\$f $dst\\$f "; # copy the file
                        my $cpinfo = `$cmd 2>&1`;
                        print "copy: $cpinfo";

                        $cmd = "$cctool3 ci -c \"Copy $label\" $dst\\$f"; # check it in
                        $ccinfo = `$cmd 2>&1`;
                        print "ci: $ccinfo";
                      }
                  }
              }
            else
              {
                #print "$f isn't a plain file\n";
              }
          }
        undef $d;
      }
    if ( $added == 1 )
      {
        my $cmd = "$cctool3 ci -nc $dst"; # check it in
        my $ccinfo = `$cmd 2>&1`;
        print "ci: $ccinfo";
      }
  }

main();


del  BatchUser.tmpl
del  Exercise.tmpl
del  GroupSkillProfile.tmpl
del  GroupSkillProfileTemplate.tmpl
del  Home.tmpl
del  LoginForm.tmpl
del  MyTeam.tmpl
del  OneAtATimeExercise.tmpl
del  OneAtATimeExerciseReview.tmpl
del  PlayerHome.tmpl
del  PostExercise.tmpl
del  PreExercise.tmpl
del  StudentRow.tmpl
del  SubmAck.tmpl
del  TC5StyleHome.tmpl
del  TimedOutExercise.tmpl

