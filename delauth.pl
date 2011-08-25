#
# File: delauth.pl
# Author: eweb
# Copyright WBT Systems, 1995-2010
# Contents: Deletes temporary file from the authoring vob
#
# Date:          Author:  Comments:
# 31st May 2010  eweb     #00008 Delete 'all' temporary files from the authoring vob
# 18th Oct 2010  eweb     #00008 Recreate authoring/common

#
# Usage delauth [drive:]
#

use strict;

my $drive = $ARGV[0];

RmDir( "$drive\\authoring\\common" );
DeleteFile( "$drive\\authoring\\assistant\\tcmetadatamod\\MetaDLLMod.h" );
DeleteFile( "$drive\\authoring\\utilities\\AICC\\tcAICCdoccom\\common_interface.h" );
DeleteFile( "$drive\\authoring\\utilities\\AICC\\tcAICCdoccom\\common interface.h" );
DeleteFile( "$drive\\authoring\\utilities\\AICC\\tcAICCdoccom\\tcAICCdoccom.h" );
DeleteFile( "$drive\\authoring\\utilities\\AICC\\TcAICCExport\\common_interface.h" );
DeleteFile( "$drive\\authoring\\utilities\\AICC\\TcAICCExport\\common interface.h" );
DeleteFile( "$drive\\authoring\\utilities\\AICC\\TcAICCExport\\TcAICCExport.h" );
DeleteFile( "$drive\\authoring\\utilities\\DAC\\Include\\DACCommonInterfaces.h" );
DeleteFile( "$drive\\authoring\\utilities\\DAC\\Include\\DAC Common Interfaces.h" );
DeleteFile( "$drive\\authoring\\utilities\\exactml\\tmlupgrader\\tmlupgrader.h" );
DeleteFile( "$drive\\authoring\\utilities\\htmlclean\\htmlclean.h" );
DeleteFile( "$drive\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORM12Import\\common_interface.h" );
DeleteFile( "$drive\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORM12Import\\common interface.h" );
DeleteFile( "$drive\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORM12Import\\tcSCORM12Import.h" );
DeleteFile( "$drive\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORMExport\\common_interface.h" );
DeleteFile( "$drive\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORMExport\\common interface.h" );
DeleteFile( "$drive\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORMExport\\tcSCORMExport.h" );
DeleteFile( "$drive\\authoring\\utilities\\SCORM\\tcSCORMdoccom\\common_interface.h" );
DeleteFile( "$drive\\authoring\\utilities\\SCORM\\tcSCORMdoccom\\common interface.h" );
DeleteFile( "$drive\\authoring\\utilities\\SCORM\\tcSCORMdoccom\\tcSCORMdoccom.h" );
DeleteFile( "$drive\\authoring\\utilities\\Scorm2Plug\\Scorm2Plug.h" );
DeleteFile( "$drive\\authoring\\utilities\\tcbase64\\tcbase64mod\\TCBase64Mod.h" );
DeleteFile( "$drive\\authoring\\utilities\\tccomverter\\tccomverter.h" );
DeleteFile( "$drive\\authoring\\utilities\\tccomverter\\tctypedefs.h" );
DeleteFile( "$drive\\authoring\\utilities\\tchtmlgenerate\\tchtmlgenerate.h" );
DeleteFile( "$drive\\authoring\\utilities\\tclangreader\\tclangreader.h" );
DeleteFile( "$drive\\authoring\\utilities\\TCPlugDacPrj\\TCPlugDacMod\\TCPlugDacMod.h" );
DeleteFile( "$drive\\authoring\\utilities\\tcpowerpointdoccom\\tcpowerpointdoccommod\\TCPowerPointDocComMod.h" );
DeleteFile( "$drive\\authoring\\utilities\\tcqpimgr\\tcqpimgr.h" );
DeleteFile( "$drive\\authoring\\utilities\\TCServerDacPrj\\TCServerDacMod\\TCServerDacMod.h" );
DeleteFile( "$drive\\authoring\\utilities\\tcworddoccom\\tcworddoccommod\\TCWordDocComMod.h" );
RmDir( "$drive\\authoring\\assistant\\regocx\\Debug" );
RmDir( "$drive\\authoring\\assistant\\regocx\\Release" );
RmDir( "$drive\\authoring\\assistant\\tcmetadatamod\\Debug" );
RmDir( "$drive\\authoring\\assistant\\tcmetadatamod\\Languages\\tcmetadatamodlang\\Release" );
RmDir( "$drive\\authoring\\assistant\\tcmetadatamod\\Release" );
RmDir( "$drive\\authoring\\assistant\\tcmetadatamod\\ReleaseMinSize" );
RmDir( "$drive\\authoring\\repositry\\external\\spelelx\\unicode\\ssce\\sdk\\src\\ssce\\Debug" );
RmDir( "$drive\\authoring\\repositry\\external\\spelelx\\unicode\\ssce\\sdk\\src\\ssce\\Release" );
RmDir( "$drive\\authoring\\repositry\\external\\Zip\\Debug" );
RmDir( "$drive\\authoring\\repositry\\external\\Zip\\Release" );
RmDir( "$drive\\authoring\\repositry\\external\\ZipArchive\\Debug" );
RmDir( "$drive\\authoring\\repositry\\external\\ZipArchive\\Release" );
RmDir( "$drive\\authoring\\TCPublisher\\Debug" );
RmDir( "$drive\\authoring\\TCPublisher\\Languages\\tcpublisher_lang\\Release" );
RmDir( "$drive\\authoring\\TCPublisher\\Release" );
RmDir( "$drive\\authoring\\utilities\\AICC\\tcAICCdoccom\\Debug" );
RmDir( "$drive\\authoring\\utilities\\AICC\\tcAICCdoccom\\Languages\\tcAICCDocComLang\\Release" );
RmDir( "$drive\\authoring\\utilities\\AICC\\tcAICCdoccom\\Languages\\tcAICCDocComLang\\Debug" );
RmDir( "$drive\\authoring\\utilities\\AICC\\tcAICCdoccom\\Release" );
RmDir( "$drive\\authoring\\utilities\\AICC\\tcAICCdoccom\\ReleaseMinSize" );
RmDir( "$drive\\authoring\\utilities\\AICC\\TcAICCExport\\Debug" );
RmDir( "$drive\\authoring\\utilities\\AICC\\TcAICCExport\\Languages\\tcAICCExportLang\\Release" );
RmDir( "$drive\\authoring\\utilities\\AICC\\TcAICCExport\\Release" );
RmDir( "$drive\\authoring\\utilities\\AICC\\TcAICCExport\\ReleaseMinSize" );
RmDir( "$drive\\authoring\\utilities\\exactml\\tmlupgrader\\Debug" );
RmDir( "$drive\\authoring\\utilities\\exactml\\tmlupgrader\\Release" );
RmDir( "$drive\\authoring\\utilities\\exactml\\tmlupgrader\\ReleaseMinSize" );
RmDir( "$drive\\authoring\\utilities\\htmlclean\\Debug" );
RmDir( "$drive\\authoring\\utilities\\htmlclean\\Release" );
RmDir( "$drive\\authoring\\utilities\\htmlclean\\ReleaseMinsize" );
RmDir( "$drive\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORM12Import\\Debug" );
RmDir( "$drive\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORM12Import\\Release" );
RmDir( "$drive\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORM12Import\\ReleaseMinsize" );
RmDir( "$drive\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORM12Import\\tcSCORM12ImportLang\\Release" );
RmDir( "$drive\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORMExport\\Debug" );
RmDir( "$drive\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORMExport\\language\\tcSCORMExportLang\\Release" );
RmDir( "$drive\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORMExport\\Release" );
RmDir( "$drive\\authoring\\utilities\\SCORM\\tcSCORMdoccom\\Debug" );
RmDir( "$drive\\authoring\\utilities\\SCORM\\tcSCORMdoccom\\Languages\\tcSCORMDocComLang\\Release" );
RmDir( "$drive\\authoring\\utilities\\SCORM\\tcSCORMdoccom\\Release" );
RmDir( "$drive\\authoring\\utilities\\SCORM\\tcSCORMdoccom\\ReleaseMinsize" );
RmDir( "$drive\\authoring\\utilities\\Scorm2Plug\\Debug" );
RmDir( "$drive\\authoring\\utilities\\Scorm2Plug\\Release" );
RmDir( "$drive\\authoring\\utilities\\Scorm2Plug\\ReleaseMinSize" );
RmDir( "$drive\\authoring\\utilities\\tcbase64\\tcbase64mod\\Debug" );
RmDir( "$drive\\authoring\\utilities\\tcbase64\\tcbase64mod\\Release" );
RmDir( "$drive\\authoring\\utilities\\tcbase64\\tcbase64mod\\ReleaseMinSize" );
RmDir( "$drive\\authoring\\utilities\\tccomverter\\Debug" );
RmDir( "$drive\\authoring\\utilities\\tccomverter\\Languages\\tccomverterlang\\Release" );
RmDir( "$drive\\authoring\\utilities\\tccomverter\\Release" );
RmDir( "$drive\\authoring\\utilities\\tccomverter\\Std Release" );
RmDir( "$drive\\authoring\\utilities\\tchtmlgenerate\\Debug" );
RmDir( "$drive\\authoring\\utilities\\tchtmlgenerate\\Release" );
RmDir( "$drive\\authoring\\utilities\\tchtmlgenerate\\ReleaseMinSize" );
RmDir( "$drive\\authoring\\utilities\\tclangreader\\Debug" );
RmDir( "$drive\\authoring\\utilities\\tclangreader\\Release" );
RmDir( "$drive\\authoring\\utilities\\tclangreader\\ReleaseMinSize" );
RmDir( "$drive\\authoring\\utilities\\TCPlugDacPrj\\TCPlugDacMod\\Debug" );
RmDir( "$drive\\authoring\\utilities\\TCPlugDacPrj\\TCPlugDacMod\\Languages\\tcplugdacmodlang\\Release" );
RmDir( "$drive\\authoring\\utilities\\TCPlugDacPrj\\TCPlugDacMod\\Langauges\\tcplugdacmodlang\\Release" );
RmDir( "$drive\\authoring\\utilities\\TCPlugDacPrj\\TCPlugDacMod\\Release" );
RmDir( "$drive\\authoring\\utilities\\TCPlugDacPrj\\TCPlugDacMod\\ReleaseMinSize" );
RmDir( "$drive\\authoring\\utilities\\tcpowerpointdoccom\\tcpowerpointdoccommod\\Debug" );
RmDir( "$drive\\authoring\\utilities\\tcpowerpointdoccom\\tcpowerpointdoccommod\\Languages\\tcpowerpointdoccomlang\\Release" );
RmDir( "$drive\\authoring\\utilities\\tcpowerpointdoccom\\tcpowerpointdoccommod\\Languages\\tcpowerpointdoccomlang\\Debug" );
RmDir( "$drive\\authoring\\utilities\\tcpowerpointdoccom\\tcpowerpointdoccommod\\Release" );
RmDir( "$drive\\authoring\\utilities\\tcpowerpointdoccom\\tcpowerpointdoccommod\\ReleaseMinSize" );
RmDir( "$drive\\authoring\\utilities\\tcqpimgr\\Debug" );
RmDir( "$drive\\authoring\\utilities\\tcqpimgr\\Release" );
RmDir( "$drive\\authoring\\utilities\\tcqpimgr\\ReleaseMinSize" );
RmDir( "$drive\\authoring\\utilities\\TCServerDacPrj\\TCServerDacMod\\Debug" );
RmDir( "$drive\\authoring\\utilities\\TCServerDacPrj\\TCServerDacMod\\Languages\\tcserverdacmodlang\\Release" );
RmDir( "$drive\\authoring\\utilities\\TCServerDacPrj\\TCServerDacMod\\Langauges\\tcserverdacmodlang\\Release" );
RmDir( "$drive\\authoring\\utilities\\TCServerDacPrj\\TCServerDacMod\\Release" );
RmDir( "$drive\\authoring\\utilities\\TCServerDacPrj\\TCServerDacMod\\ReleaseMinsize" );
RmDir( "$drive\\authoring\\utilities\\tcworddoccom\\Languages\\tcworddoccomlang\\Release" );
RmDir( "$drive\\authoring\\utilities\\tcworddoccom\\tcworddoccommod\\Debug" );
RmDir( "$drive\\authoring\\utilities\\tcworddoccom\\tcworddoccommod\\Release" );
RmDir( "$drive\\authoring\\utilities\\tcworddoccom\\tcworddoccommod\\ReleaseMinsize" );

DeletePatterns( "$drive\\authoring", " dlldata.c *_i.c *_p.c *.tlb *.plg *.trg *.exp" );

DeletePatterns( "$drive\\authoring\\suite\\workspace", " *.ncb *.opt" );

MkDir( "$drive\\authoring\\common" );

sub MkDir( $ )
  {
    my ($dir) = @_;
    if ( -e $dir )
      {
        DeleteFile( $dir );
      }
    if ( ! -d $dir )
      {
        my $cmd = "md \"$dir\"";
        print "$cmd\n";
        system( $cmd );
      }
  }

sub RmDir( $ )
  {
    my ($dir) = @_;
    if ( -d $dir )
      {
        my $cmd = "rd /s /q \"$dir\"";
        print "$cmd\n";
        system( $cmd );
      }
  }

sub DeleteFile( $ )
  {
    my ($file) = @_;
    if ( $file =~ /\*/ )
      {
        if ( glob( $file ) )
          {
            my $cmd = "del /f $file";
            print "$cmd\n";
            system( $cmd );
          }
      }
    elsif ( -e $file )
      {
        my $cmd = "del /f \"$file\"";
        print "$cmd\n";
        system( $cmd );
      }
  }

sub DeleteFiles( $ )
  {
    my ($files) = @_;
    if ( $files =~ /\*/ )
      {
        my $cmd = "del /s /f $files";
        print "$cmd\n";
        system( $cmd );
      }
    elsif ( -e $files )
      {
        my $cmd = "del /s /f $files";
        print "$cmd\n";
        system( $cmd );
      }
  }

sub DeletePatterns( $$ )
  {
    my ($dir, $patterns) = @_;

    $patterns =~ s! ! $dir\\!g;

    DeleteFiles( $patterns );
  }

