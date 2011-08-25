#******************************************************************************/
#
#  File: appName.pl
#  Author: eweb
#  Copyright WBT Systems, 2006-2007
#  Contents:
#
#******************************************************************************/
#
# Date:          Author:  Comments:
#  5th Nov 2007  eweb     #00008 always use the app name.

use strict;

use Getopt::Std;

my %opts = ( d => undef(),
             C => undef(),
             m => undef(),
             n => undef(),
             p => undef(),
             b => undef(),
             M => undef(),
             I => undef(),
           );

# Was anything other than the defined option entered on the command line?
if ( !getopts("d:C:m:n:p:b:M:I:", \%opts) or @ARGV > 1 )
  {
    print STDERR "Unknown arg $ARGV[0]\n" if @ARGV > 0;
    #Usage();
    exit;
  }

my $cctool1 = "cleartool"; # info
my $cctool2 = "cleartool"; # reversable check outs
my $cctool3 = "echo not cleartool"; # allow manual check before checkin
#my $cctool4 = "echo not cleartool"; # destructive

if ( $opts{d} eq "Y" )
  {
    $cctool3 = "cleartool"
  }

my $ccdrive = $opts{d};

my $projHome = "$ccdrive\\topclass\\java\\cnr";
print "$projHome \n";

my $cust = $opts{C};
my $name = $opts{M};

if ( $name eq "" )
  {
    $name = "cnr";
  }

if ( $cust ne "" )
  {
    $name = $name . $cust;
  }

$name = $name . $opts{m} . $opts{n} . $opts{p};

if ( $opts{b} ne "" )
  {
     $name = $name . "b" . $opts{b};
  }

print "$name\n";

#.project(3): <name>cnr742</name>
my $file = "$projHome\\.project";

if ( !open( IN, $file ) )
  {
    print "Can't open $file\n";
  }
else
  {
    print "$file\n";
    my @lines = <IN>;
    close( IN );
    if ( $lines[2] =~ /<name>(.+)<\/name>/ )
      {
        if ( $1 eq $name )
          {
            print "No change in name $1 eq $name\n";
          }
        else
          {
            print "Change name from $1 to $name\n";
            $lines[2] =~ s!$1!$name!;
            CheckOut( $file );
            if ( !open( OUT, ">$file" ) )
              {
                print "Can't open $file for writing\n";
              }
            else
              {
                foreach ( @lines )
                  {
                    print OUT;
                  }
                close( OUT );
              }
            CheckIn( $file );
          }
      }
  }

#build.xml(8): <property name="app.name"       value="cnr"/>
$file = "$projHome\\build.xml";
if ( !open( IN, $file ) )
  {
    print "Can't open $file\n";
  }
else
  {
    print "$file\n";
    my @lines = <IN>;
    close( IN );
    foreach ( @lines )
      {
        if ( /<property name="app.name"\s+value="(.+)"\/>/ )
          {
            if ( $1 eq $name )
              {
                print "No change in name $1 eq $name\n";
              }
            else
              {
                print "Change name from $1 to $name\n";
                s!$1!$name!;
                CheckOut( $file );
                if ( !open( OUT, ">$file" ) )
                  {
                    print "Can't open $file for writing\n";
                  }
                else
                  {
                    foreach ( @lines )
                      {
                        print OUT;
                      }
                    close( OUT );
                  }
                CheckIn( $file );
              }
            last;
          }
      }
  }


#WebContent\WEB-INF\log.properties(6): log4j.appender.F1.File=${wbtwebapp.logsdir}/cnrapp.log

$file = "$projHome\\WebContent\\WEB-INF\\log.properties";

if ( !open( IN, $file ) )
  {
    print "Can't open $file\n";
  }
else
  {
    print "$file\n";
    my @lines = <IN>;
    close( IN );
    foreach ( @lines )
      {
        if ( /log4j\.appender\.F1\.File=\$\{wbtwebapp\.logsdir\}\/(.+)app\.log/ )
          {
            if ( $1 eq $name )
              {
                print "No change in name $1 eq $name\n";
              }
            else
              {
                print "Change name from $1 to $name\n";
                s!$1!$name!;
                CheckOut( $file );
                if ( !open( OUT, ">$file" ) )
                  {
                    print "Can't open $file for writing\n";
                  }
                else
                  {
                    foreach ( @lines )
                      {
                        print OUT;
                      }
                    close( OUT );
                  }
                CheckIn( $file );
              }
            last;
          }
      }
  }


#.settings\org.eclipse.wst.common.component(3): <wb-module deploy-name="cnr742">
#.settings\org.eclipse.wst.common.component(8): <property name="context-root" value="cnr742"/>
$file = "$projHome\\.settings\\org.eclipse.wst.common.component";

if ( !open( IN, $file ) )
  {
    print "Can't open $file\n";
  }
else
  {
    print "$file\n";
    my @lines = <IN>;
    close( IN );
    foreach ( @lines )
      {
        if ( /<wb-module deploy-name="(.+)">/ )
          {
            if ( $1 eq $name )
              {
                print "No change in name $1 eq $name\n";
              }
            else
              {
                print "Change name from $1 to $name\n";
                s!$1!$name!;
                CheckOut( $file );
                if ( !open( OUT, ">$file" ) )
                  {
                    print "Can't open $file for writing\n";
                  }
                else
                  {
                    foreach ( @lines )
                      {
                        print OUT;
                      }
                    close( OUT );
                  }
                CheckIn( $file );
              }
          }
        if ( /<property name="context-root" value="(.+)"\/>/ )
          {
            if ( $1 eq $name )
              {
                print "No change in name $1 eq $name\n";
              }
            else
              {
                print "Change name from $1 to $name\n";
                s!$1!$name!;
                CheckOut( $file );
                if ( !open( OUT, ">$file" ) )
                  {
                    print "Can't open $file for writing\n";
                  }
                else
                  {
                    foreach ( @lines )
                      {
                        print OUT;
                      }
                    close( OUT );
                  }
                CheckIn( $file );
              }
          }
      }
  }

$file = "$projHome\\WebContent\\WEB-INF\\web.xml";
#WebContent\WEB-INF\web.xml(17):
#  <servlet>
#    <servlet-name>Startup</servlet-name>
#    <servlet-class>com.wbtsystems.cnr.util.CNRStartup</servlet-class>
#    <init-param>
#      <param-name>appname</param-name>
#      <param-value>cnr742</param-value>
#    </init-param>
#    <load-on-startup>1</load-on-startup>
#  </servlet>


if ( !open( IN, $file ) )
  {
    print "Can't open $file\n";
  }
else
  {
    print "$file\n";
    my @lines = <IN>;
    close( IN );
    my $servlet = 0;
    my $servletname = "";
    my $paramname = "";

    foreach ( @lines )
      {
        if ( /<servlet>/ )
          {
            $servlet = 1;
            $servletname = "";
            $paramname = "";
          }
        if ( /<\/servlet>/ )
          {
            $servlet = 0;
            $servletname = "";
            $paramname = "";
          }
        if ( /<servlet-name>(.+)<\/servlet-name>/ )
          {
            $servletname = $1;
          }
        if ( /<param-name>(.+)<\/param-name>/ )
          {
            $paramname = $1;
          }
        if ( /<param-value>(.+)<\/param-value>/ )
          {
            my $paramvalue = $1;
            if ( $servletname eq "Startup" and $paramname eq "appname" )
              {
                if ( $1 eq $name )
                  {
                    print "No change in name $1 eq $name\n";
                  }
                else
                  {
                    print "Change name from $1 to $name\n";
                    s!$1!$name!;
                    CheckOut( $file );
                    if ( !open( OUT, ">$file" ) )
                      {
                        print "Can't open $file for writing\n";
                      }
                    else
                      {
                        foreach ( @lines )
                          {
                            print OUT;
                          }
                        close( OUT );
                      }
                    CheckIn( $file );
                  }
                last;
              }
          }
      }
  }

sub CheckIn($$)
  {
    my ($file, $comment) = @_;
    if ( $comment eq "" )
      {
        $comment = "#00001 Changing name to $name";
      }

    my $cmd = "$cctool3 ci -c \"$comment\" \"$file\"";
    print "$cmd\n";
    my $results = `$cmd 2>&1`;

    if ( $results =~ /Error: By default, won't create version with data identical to predecessor./ )
      {
        # hasn't changed so undo the check out.
        $cmd = "$cctool3 unco -rm \"$file\"";
        $results = $results . "\n" . $cmd . "\n" . `$cmd 2>&1`;
      }
    elsif ( $results =~ /Error: Not an element:/ )
      {
        # Not an element
      }
    elsif ( $results =~ /Error:/ )
      {
        # Not an element
      }
    else
      {
        # Not an element
      }
    print "$results\n";
  }

sub CheckOut($$)
  {
    my ($file, $comment) = @_;
    if ( $comment eq "" )
      {
        $comment = "#00001 Changing name to $name";
      }

    my $cmd = "$cctool2 co -c \"$comment\" \"$file\"";

    print "$cmd\n";

    my $results = `$cmd 2>&1`;

    if ( $results =~ /Error: Element "(.+)" is already checked out to view "(.+)"/ )
      {
      }
    elsif ( $results =~ /Error: Not a vob object:/ )
      {
        # Not an element
      }
    elsif ( $results =~ /Error: / )
      {
      }

    print "$results\n";
  }

=begin comment

=end comment

=cut
