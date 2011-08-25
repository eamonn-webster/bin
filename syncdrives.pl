# syncdrives
#
# Sync drives (possibly clearcase views) with another drive (e.g. a USB drive)
#
# for each drive
# sync it

use strict;

my $usb = "e:";

my $configSpecs = "c:/temp/configspecs";


#my $sync = "echo cc2drive";

#$cc2drive = "echo cc2drive";
#$cc2drive3 = "echo cc2drive3";

# can we write a config spec to select the correct version?

my @Configs =
(
  "314, TC_314_BASE,              ,               eweb_314",
  "428, TC_421_BUILD_128,         428_Dow_branch, eweb_428_dow",
  "521, TC_520_RELEASE_BUILD_256, 521_branch,     eweb_521_2",
# "614, TC_610_BUILD_102,         610_branch,     eweb_614_126",
# "622, TC_621_BUILD_164,         621_branch,     eweb_621_7067",
# "630, TC_621_BUILD_164,         630_branch,     630_branch_volvo",
  "633, TC_621_BUILD_164,         630_branch,     eweb_633_work_1",
  "715, TC_710_BUILD_096,         710_branch,     eweb_715_work_1",
  "724, TC_720_BUILD_226,         721_branch,     eweb_724_work_1",
  "733, TC_730_BUILD_110,         73x_branch,     eweb_732_work_4",
  "740, ,                         ,               eweb_740_work_9",
);

@Configs =
(
  #   label             branch      workbranch
  "1, TC_123_BUILD_789, 123_branch, eweb_123_work",    # /main/$branch/$workbranch/LATEST, /main/$branch/LATEST -mkbranch $workbranch, /main/$label -mkbranch $branch
  "2, TC_123_BUILD_789, 123_branch, ",                 #
  "3, TC_123_BUILD_789, ,           eweb_123_work",    #
  "4, TC_123_BUILD_789, ,           ",                 # TC_123_BUILD_789
  "5, ,                 123_branch, eweb_123_work",    # error
  "6, ,                 123_branch, ",                 # error
  "7, ,                 ,           eweb_123_work",    # /main/eweb_123_work/LATEST, /main/LATEST -mkbranch eweb_123_work
  "8, ,                 ,           ",                 # /main/LATEST
);

sub writeConfigSpec($$$$$)
  {
    my ( $ver, $label, $branch, $workbranch, $checkouts ) = @_;

    # cases 5 6
    if ( $label eq "" and $branch ne "" )
      {
        print "Branch but no label\n";
        return;
      }

    my $cs = "$configSpecs/tc$ver.cs";
    if ( -e $cs )
      {
        unlink( "$cs.bak" );
        rename( $cs, "$cs.bak" );
      }
    if ( open( CONFIG, "$cs" ) )
      {
        # already exists
        close( CONFIG );
      }
    elsif ( open( CONFIG, ">$cs" ) )
      {
        print CONFIG "# Generated Config Spec for $ver\n\n";
        if ( $checkouts eq "Y" )
          {
            print CONFIG "element * CHECKEDOUT\n";
          }
        elsif ( $workbranch ne "" )
          {
            print CONFIG "element * CHECKEDOUT\n";
          }

        # case 1 label, branch and workbranch
        if ( $label ne "" and $branch ne "" and $workbranch ne "" )
          {
            print CONFIG "element * /main/$branch/$workbranch/LATEST\n";
            print CONFIG "element * /main/$branch/LATEST -mkbranch $workbranch\n";
            print CONFIG "element * /main/$label -mkbranch $branch\n";
            print CONFIG "#element * /main/LATEST -mkbranch $branch\n";
          }
        # case 2 label, branch but no workbranch
        elsif ( $label ne "" and $branch ne "" and $workbranch eq "" )
          {
            print CONFIG "element * /main/$branch/LATEST\n";
            print CONFIG "element * /main/$label -mkbranch $branch\n";
            print CONFIG "#element * /main/LATEST -mkbranch $branch\n";
          }
        # case 3 label, workbranch but no branch
        elsif ( $label ne "" and $branch eq "" and $workbranch ne "" )
          {
            print CONFIG "element * /main/$workbranch/LATEST\n";
            print CONFIG "element * /main/$label -mkbranch $workbranch\n";
            print CONFIG "#element * /main/LATEST -mkbranch $workbranch\n";
          }
        # case 4 just a label no branch...
        elsif ( $label ne "" and $branch eq "" and $workbranch eq "" )
          {
            print CONFIG "element * $label\n";
            print CONFIG "#element * /main/LATEST\n";
          }
        # case 7 just a workbranch...
        elsif ( $label eq "" and $branch eq "" and $workbranch ne "" )
          {
            print CONFIG "element * /main/$workbranch/LATEST\n";
            print CONFIG "element * /main/LATEST -mkbranch $workbranch\n";
          }
        # case 8 no label, or branch
        if ( $label eq "" and $branch eq "" and $workbranch eq "" )
          {
            print CONFIG "element * /main/LATEST\n";
          }
        print CONFIG "\n";
        close( CONFIG );
        $cs =~ s!/!\\!g;
        system( "type $cs" );
        #system( "del $cs" );
      }
  }
# Generic 633

#element * /main/630_branch/eweb_633_work_1/LATEST
#element * /main/630_branch/LATEST -mkbranch eweb_633_work_1
#element * /main/TC_621_BUILD_164 -mkbranch 630_branch

sub checkBuildNoDotH( $$$$$ )
  {
    my ($drive, $major, $minor, $point, $build ) = @_;
    my $buildnoh = "$drive/topclass/oracle/topclass/sources/buildno.h";

    if ( ! -e $buildnoh )
      {
        $buildnoh = "$drive/topclass/neo/sources/buildno.h";
      }

    if ( open( BUILDNO, "$buildnoh" ) )
      {
        while ( <BUILDNO> )
          {
            if ( /define BUILDNUMBER\s+([0-9]+)/ )
              {
                $$build = $1;
              }
            elsif ( /define MAJORREVISION\s+([0-9]+)/ )
              {
                $$major = $1;
              }
            elsif ( /define MINORREVISION\s+([0-9]+)/ )
              {
                $$minor = $1;
              }
            elsif ( /define POINTREVISION\s+([0-9]+)/ )
              {
                $$point = $1;
              }
          }
        close( BUILDNO );
        #print "$$major $$minor $$point $$build\n";
      }
    else
      {
        print "Couldn't open $buildnoh\n";
      }
  }

sub processDrives($)
  {
    my ($sync) = @_;
    if ( open( SUBST, "subst |" ) )
      {
        while ( <SUBST> )
          {
            chomp;
            if ( /(.:)\\: => M:\\(.*)/i )
              {
                my $drive = "$1";
                my $tag = $2;
                #print "cleacase drive: $drive view: $tag\n";
                my $ver;
                if ( $tag =~ /eweb_([0-9]{3})/ )
                  {
                    $ver = $1;
                  }
                elsif ( $tag =~ /eweb_([0-9]{2})/ )
                  {
                    $ver = $1;
                  }
                elsif ( $tag =~ /eweb_([0-9]{3})_[a-z]+/ )
                  {
                    $ver = $1;
                  }
                elsif ( $tag =~ /eweb_work_([0-9]{3})/ )
                  {
                    $ver = $1;
                  }
                elsif ( $tag =~ /eweb_(.*)/ )
                  {
                  }
                if ( $ver ne "" )
                  {
                    my $major;
                    my $minor;
                    my $point;
                    my $build;
                    checkBuildNoDotH( $drive, \$major, \$minor, \$point, \$build );
                    if ( "$major$minor$point" ne $ver )
                      {
                        #print "buildno.h: $major$minor$point view $ver \n";
                        $ver = "$major$minor$point";
                      }
                    if ( $sync eq "dobuild" )
                      {
                        system( "$sync $drive" );
                      }
                    else
                      {
                        my $cmd = $sync;
                        if ( $major eq "3" && $sync ne "echo" )
                          {
                            $cmd = $sync . "3";
                          }
                        system( "$cmd tc$ver $usb $drive" );
                      }
                  }
              }
            elsif ( /(.:)\\: => C:\\cpp\\(.*)/i )
              {
                my $drive = $1;
                my $dir = $2;
                print "subst drive: $drive tcver: $dir\n";
                if ( $dir =~ /tc([0-9]{3})/ )
                  {
                    my $ver = $1;
                    my $major;
                    my $minor;
                    my $point;
                    my $build;
                    checkBuildNoDotH( $drive, \$major, \$minor, \$point, \$build );
                    if ( "$major$minor$point" ne $ver )
                      {
                        #print "buildno.h: $major$minor$point view $ver \n";
                        $ver = "$major$minor$point";
                      }
                    if ( $sync eq "dobuild" )
                      {
                        system( "$sync $drive" );
                      }
                    else
                      {
                        my $cmd = $sync;
                        if ( $major eq "3" && $sync ne "echo" )
                          {
                            $cmd = $sync . "3";
                          }
                        system( "$cmd tc$ver $usb" );
                     }
                  }
              }
            else
              {
                print "Unknown $_\n";
              }
          }
        close( SUBST );
      }
  }

#my ( $ver, $label, $branch, $workbranch ) = ( $ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3] );

sub genall()
  {
    for my $x ( @Configs )
      {
        #print "$x\n";
        my ( $ver, $label, $branch, $workbranch ) = split( ", *", $x );
        #print "[$ver][$label][$branch][$workbranch]\n";
        writeConfigSpec( $ver, $label, $branch, $workbranch, "Y" );
      }
  }

#my ( $ver, $label, $branch, $workbranch ) = ( $ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3] );
#writeConfigSpec( $ver, $label, $branch, $workbranch, "Y" );

if ( $ARGV[0] eq "to" )
  {
    processDrives( "cc2drive" );
  }
elsif ( $ARGV[0] eq "fro" )
  {
    processDrives( "drive2cc" );
  }
elsif ( $ARGV[0] eq "show-to" )
  {
    processDrives( "echo cc2drive" );
  }
elsif ( $ARGV[0] eq "show-fro" )
  {
    processDrives( "echo drive2cc" );
  }
elsif ( $ARGV[0] eq "dobuild" )
  {
    processDrives( "dobuild" );
  }
else
  {
    processDrives( "echo" );
  }
#genall();

