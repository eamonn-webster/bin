#******************************************************************************
#
#  File: jan08.pl
#  Author: eweb
#  Copyright WBT Systems, 2005-2008
#  Contents: Scan source files for old names converting to new names
#
#******************************************************************************
#
# Date:          Author:  Comments:

use strict;
use HTML::Entities;
use File::Find;
use File::Basename;
use Getopt::Std;

my $count = 0;

my %opts = ( d => undef(),
             L => undef(),
             v => undef(),
             Z => undef(),
           );

# Was anything other than the defined option entered on the command line?
if ( !getopts("d:L:v:Z:V:", \%opts) or @ARGV > 0 )
  {
    print STDERR "Unknown arg $ARGV[0]\n\n" if @ARGV > 0;
    #Usage();
  }

my $bugz = "http://bunny.wbt.wbtsystems.com/";
if ( defined($opts{Z}) ) {
  $bugz = $opts{Z};
}
my $drive = $opts{d};
my $logDir = $opts{L};
my $version = $opts{v};
my $verbose = $opts{V};

#my @excludes = qw/META-INF\\\\mailcap kDefault.+Template\.inc/;
my @good = qw/.cpp .h/;
#my @bad = qw/.500 .a .bak .bin .bmp .bsc .cfg .ckp .class .cmd .conf .contrib .dat_edusoft .dbt .dll .doc .dsp .dsw .exe .exp .fmt .gif .gnu .h~ .htm .ico .idb .ilk .ion .jar .jpg .jtl .labels .lang .lib .lic .lnt .log .mak .map .mk .mkf .ncb .new .nlb .o .obj .old .opt .par .pch .pdb .plg .r .reg .res .rh .sbr .ser .server .sln .sun .tclog .tlh .tli .txt .vbs .vcproj .vspscc .vssscc .war .xls .xsd .plb .png .keep/;
#my @ugly;

my @directories_to_search = ( "$drive/topclass/oracle/topclass" );

@directories_to_search = ( "$drive/topclass/oracle/topclass" );

my @directories_to_exclude = ( "$drive/topclass/java/topclass/build", "$drive/topclass/oracle/topclass/www/chelp", "$drive/topclass/oracle/topclass/www/yui" );

if ( $version ne "" and $version lt "9.0.0" ) {
    #@directories_to_search = ( "$drive/topclass/java", "$drive/topclass/oracle/topclass" );
    @directories_to_search = ( "$drive/topclass/oracle/topclass" );
    #@directories_to_search = ( "$drive/topclass/java/cnr/src" );
}

my %substitutions = (
  FALSE          => "false",
  fattrName      => "fattrName",
  fattrs         => "fattrs",
  fclassId       => "fclassId",
  fmodifiable    => "fmodifiable",
  fnumAttrs      => "fnumAttrs",
  freadName      => "freadName",
  ftag           => "ftag",
  ftagType       => "ftagType",
  fwriteName     => "fwriteName",
  neoAttrDesc    => "neoAttrDesc",
  neoObjAttrDesc => "NeoObjAttrDesc",
  neoObjDesc     => "CNeoObjDesc",
  NULL           => "0",
  TRUE           => "true",
);

print "\@directories_to_search @directories_to_search\n";

sub exclude_dir ($) {
  my ($dir) = @_;
  $dir =~ s!\\!/!g;
  foreach my $exdir (@directories_to_exclude) {
      $exdir =~ s!\\!/!g;
      if ( $dir =~ /$exdir/ ) {
          print "exclude $exdir & $dir\n" if ( $verbose );
          return 1;
      }
  }
  #print "keeping $exdir & $dir\n" if ( $verbose );
}

sub wanted {

    #$File::Find::dir  = /some/path/
    #$_                = foo.ext
    #$File::Find::name = /some/path/foo.ext

    my $file = $_;
    my $path = $File::Find::name;


    $path =~ s!/!\\!g;

    $count++;
    if ( ($count % 1000) eq 0 ) {
        print ".";
    }
    #print "$file\n" if ( $verbose );

    if ( -d $file ) {
        #print "DID $file\n" if ( $verbose );
    }
    # avoid reading the file we are writing to....
    elsif ( $file eq "todo.html" ) {
    }
    elsif ( -e $file ) {
        #print "FILE $file\n";
        my ( $name, $dir, $ext ) = fileparse($path, qr/\.[^.]*/);
        $ext = lc $ext;
        my $qdir = quotemeta( $dir );

        #foreach ( @excludes ) {
        #  if ( $path =~ /$_/ ) {
        #    print "exclude $file\n" if ( $verbose );
        #    return;
        #  }
        #}
        #if ( grep( /^$ext$/, @bad ) ) {
        #    print "BAD $file\n" if ( $verbose );
        #}
        if ( $file =~ /\.contrib\.[0-9]+/ ) {
            #print "BAD $file\n" if ( $verbose );
        }
        elsif ( exclude_dir( $dir ) ) {
            print "exclude $dir\n" if ( $verbose );
        }
        elsif ( grep( /^$ext$/, @good ) ) {
            print "GOOD $file\n" if ( $verbose );
            if ( open( FILE, $path ) ) {
                chomp;
                my $lno = 1;
                while ( <FILE> ) {
                    my $oldline = $_;
                    my $newline = $oldline;
                    foreach ( keys( %substitutions ) ) {
                      $newline =~ s!$_!$substitutions{$_}!g;
                    }
                    if ( $newline ne $oldline ) {
                      print "< $oldline";
                      print "> $newline";
                    }
                    $lno++;
                }
                close( FILE );
            }
        }
    }
    else {
        #print "NO $file\n";
    }

}


my $lastFile;

sub display($$$) {
    my ($file, $lno, $line) = @_;
    my $user = "&nbsp;";
    my $date = "&nbsp;";

    if ( $file eq $lastFile ) {
       $file = "&nbsp;";
    }
    else {
       $lastFile = $file;
       $file = encode_entities($file);
    }
    $line =~ s/^\s+//;
    #print $line;
    # remove the start comment...
    $line =~ s!^\s*#\s*!!;
    $line =~ s!^//\s*!!;
    $line =~ s!^.*//\s*TODO!TODO!;
    $line =~ s!^<\!--\s*!!;
    $line =~ s!\s*-->\s*!!;
    $line =~ s!^/\*\s*!!;
    $line =~ s!^\*\s*!!;
    $line = encode_entities($line);

    my $tdclass = "pending";
    if ( $line =~ /#([0-9]{4,5})/ ) {
        $tdclass = "success";
    }

    if ( $bugz ne "" ) {
        $line =~ s!#([0-9]{4,5})!<a href="$bugz/show_bug.cgi?id=$1">#$1</a>!;
    }


    my ( $name, $dir ) = fileparse($file);

    # undosify
    $dir =~ s!\\!/!g;
    foreach my $sdir ( @directories_to_search ) {
        if ( $dir =~ /^$sdir\/(.*)/ ) {
            #print "$dir ==> $1\n";
            $name = $1 . $name;
            last;
        }
    }

    print HTML "    <tr><td class=\"blank\" style=\"width:25%\">$name</td>\n";
    print HTML "        <td class=\"$tdclass\" style=\"width:75%\">$line</td>\n";
    print HTML "    </tr>\n";
}

#my $todofile;
#if ( $logDir ne "" ) {
#    $todofile = "$logDir\\todo.html";
#}
#else {
#    $todofile = "todo.html";
#}
#if ( open( HTML, ">$todofile" ) ) {
#    print HTML "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"  \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\n";
#    print HTML "<html>\n";
#    print HTML "<head>\n";
#    print HTML "  <title>TODO List</title>\n";
#    print HTML "  <link rel=\"stylesheet\" href=\"../../build.css\" type=\"text/css\" />\n";
#    print HTML "</head>\n";
#    print HTML "<body>\n";
#    print HTML "  <h1>TODO List\n";
#    print HTML "  <img src=\"../../yeswecan.jpg\" width=\"195\" height=\"214\" alt=\"yes we will\" />\n";
#    print HTML "  </h1>\n";
#    print HTML "  <table summary=\"Changes\">\n";
#    print HTML "    <tr><th class='header' style=\"width:25%\">File</th>\n";
#    print HTML "        <th class='header' style=\"width:75%\">Task</th>\n";
#    print HTML "    </tr>\n";


    find(\&wanted, @directories_to_search);

#    if ( $#ugly > 0 ) {
#        print HTML "    <tr><td colspan=\"2\" class=\"failure\">@ugly</td></tr>\n";
#    }

#    print HTML "  </table>\n";
#    print HTML "</body>\n";
#    print HTML "</html>\n";
#    close(HTML);
#}



