#******************************************************************************
#
#  File: checklobs.pl
#  Author: eweb
#  Copyright WBT Systems, 2006
#  Contents: Produces sql script to check clobs, based on oneowest.sql ORACLE only.
#
#******************************************************************************
#
# Date:          Author:  Comments:
# 10th Jan 2006  eweb     Initial version.
# 11th Jan 2006  eweb     Fix the problems.
# 31st Jan 2006  eweb     SQL Server.

use strict;

my $infile = @ARGV[0];
my $outfile = @ARGV[1];
my $dbms = "oracle";

if ( $infile eq "" )
  {
    $infile = "oneowest.sql"
  }
if ( $outfile eq "" )
  {
    $outfile = "checklobs.sql"
  }

if ( $infile =~ /oneowest\.sql/ )
  {
    $dbms = "oracle";
  }
else
  {
    $dbms = "mssql";
  }

my $fix = "--FIX ";
my $count = "--COUNT ";
my $detail = "--DETAIL ";

$fix = "--FIX ";
$count = "";
$detail = "";

if ( open( input, $infile ) )
  {
    if ( open( output, ">$outfile" ) )
      {
        print output "--\n";
        print output "--  File: checklobs.sql\n";
        print output "--  Author: generated\n";
        print output "--  Copyright WBT Systems, 2006\n";
        print output "--  Contents: SQL script to check / fix clobs.\n";
        print output "--\n";
        print output "--\n";
        print output "-- Remove one or more of \n";
        print output "-- --COUNT, --DETAIL, --FIX \n";
        print output "--\n";
        print output "\n";

        if ( $dbms eq "oracle" )
          {
            print output "SPOOL checkclobs.txt\n";
          }
        my $lastClass;
        while ( <input> )
          {
            if ( /CREATE TABLE S_([A-Za-z]+)_([A-Za-z]+)/ )
              {
                if ( $1 ne "WUser" )
                  {
                    #next;
                  }
                my $table = "S_$1_$2";
                my $class = $1;
                my $slot = $2;
                my $obj = $1;
                my $column = "W$2";

                if ( $slot eq "Desc" or $slot eq "Descrip" or $slot eq "Descripti" )
                  {
                    $column = "WDescription";
                  }
                if ( $class eq "WAnswer" )
                  {
                    $obj = "WAnswer_View";
                  }
                if ( $class eq "WMessage" )
                  {
                    $obj = "WMessage_View";
                  }
                print output "\n-- TABLE $table\n\n";

                # Missing rows in clob table
                #print output "SELECT '$table' AS WTable, (SELECT COUNT(1) FROM $obj) AS WObjCount, (SELECT COUNT(1) FROM $table) AS WClobCount FROM DUAL WHERE (SELECT COUNT(1) FROM $obj) <> (SELECT COUNT(1) FROM $table);\n";

                print output $count . "SELECT '$table' AS WTable, count(1), 'Missing' AS $column FROM $obj WHERE $class" . "_ID NOT IN (SELECT $class" . "_ID FROM $table);\n";

                print output $detail . "SELECT '$table' AS WTable, $class" . "_ID, 'Missing' AS $column FROM $obj WHERE $class" . "_ID NOT IN (SELECT $class" . "_ID FROM $table);\n";

                if ( $dbms eq "oracle" )
                  {
                    print output $fix . "INSERT INTO $table (SELECT $class" . "_ID, EMPTY_CLOB() FROM $obj WHERE $class" . "_ID NOT IN (SELECT $class" . "_ID FROM $table));\n";
                    print output $fix . "COMMIT;\n\n";
                  }
                else
                  {
                    print output $fix . "INSERT INTO $table (SELECT $class" . "_ID, NULL FROM $obj WHERE $class" . "_ID NOT IN (SELECT $class" . "_ID FROM $table));\n";
                    print output "\n\n";
                  }

                if ( $dbms eq "oracle" )
                  {
                    # NULL clobs
                    print output $count . "SELECT '$table' AS WTable, count(1), 'NULL' AS $column FROM $table WHERE $column IS NULL;\n";

                    print output $detail . "SELECT '$table' AS WTable, $class" . "_ID, 'NULL' AS $column FROM $table WHERE $column IS NULL;\n";

                    print output $fix . "UPDATE $table SET $column = EMPTY_CLOB() WHERE $column IS NULL;\n";
                    print output $fix . "COMMIT;\n\n";
                  }

                # Unterminated clobs
                if ( $dbms eq "oracle" )
                  {
                    print output $count . "SELECT '$table' AS WTable, count(1), 'unterminated' AS $column FROM $table WHERE dbms_lob.getlength($column) > 0 AND dbms_lob.substr($column, 1, dbms_lob.getlength($column) ) <> CHR(0);\n";

                    print output $detail . "SELECT '$table' AS WTable, $class" . "_ID, CAST( dbms_lob.substr($column, 1, dbms_lob.getlength($column)) AS VARCHAR(8) ) AS LastChar FROM $table WHERE dbms_lob.getlength($column) > 0 AND dbms_lob.substr($column, 1, dbms_lob.getlength($column)) <> CHR(0);\n";

                    print output $fix . "--UPDATE $table SET $column = $column || chr(0) WHERE dbms_lob.getlength($column) > 0 AND dbms_lob.substr($column, 1, dbms_lob.getlength($column) ) <> CHR(0);\n";
                    print output $fix . "--COMMIT;\n\n";

                    print output $fix . "BEGIN\n";
                    print output $fix . "  DECLARE CURSOR clobs IS SELECT $class" . "_ID FROM $table WHERE dbms_lob.getlength($column) > 0 AND dbms_lob.substr($column, 1, dbms_lob.getlength($column) ) <> CHR(0);\n";
                    print output $fix . "  lID NUMBER;\n";
                    print output $fix . "  lClob CLOB;\n";
                    print output $fix . "\n";
                    print output $fix . "BEGIN\n";
                    print output $fix . "  OPEN clobs;\n";
                    print output $fix . "\n";
                    print output $fix . "  LOOP\n";
                    print output $fix . "    FETCH clobs INTO lID;\n";
                    print output $fix . "    EXIT WHEN clobs%NOTFOUND;\n";
                    print output $fix . "    SELECT $column INTO lClob FROM $table WHERE $class" . "_ID = lID FOR UPDATE;\n";
                    print output $fix . "    dbms_lob.writeAppend( lClob, 1, chr(0) );\n";
                    print output $fix . "    commit;\n";
                    print output $fix . "  END LOOP;\n";
                    print output $fix . "  CLOSE clobs;\n";
                    print output $fix . "END;\n";
                    print output $fix . "END;\n";
                    print output $fix . "/\n\n";
                  }
                else
                  {
                    print output $count . "SELECT '$table' AS WTable, count(1), 'unterminated' AS $column FROM $table WHERE datalength($column) > 0 AND substring($column, datalength($column), 1 ) <> CHAR(0);\n";

                    print output $detail . "SELECT '$table' AS WTable, $class" . "_ID, substring($column, datalength($column), 1) AS LastChar FROM $table WHERE datalength($column) > 0 AND substring($column, datalength($column), 1) <> CHAR(0);\n";

                    print output $fix . "--UPDATE $table SET $column = $column + char(0) WHERE datalength($column) > 0 AND substring($column, datalength($column), 1 ) <> CHAR(0);\n";
                    print output $fix . "--COMMIT;\n\n";

                    print output $fix . "BEGIN\n";
                    print output $fix . "  DECLARE\n";
                    print output $fix . "   \@lID    INTEGER\n";
                    print output $fix . "  ,\@clobs  CURSOR\n";
                    print output $fix . "  ,\@ptrval BINARY(16)\n";
                    print output $fix . "  ,\@zero NCHAR\n";
                    print output $fix . "  ,\@length INTEGER;\n";
                    print output $fix . "\n";
                    print output $fix . "  SET \@zero = CHAR(0);\n";
                    print output $fix . "  SET \@clobs = CURSOR FOR\n";
                    print output $fix . "    SELECT $class" . "_ID\n";
                    print output $fix . "      FROM $table\n";
                    print output $fix . "     WHERE datalength($column) > 0 AND substring($column, datalength($column), 1 ) <> CHAR(0)\n";
                    print output $fix . "       FOR READ ONLY;\n";
                    print output $fix . "\n";
                    print output $fix . "  OPEN \@clobs;\n";
                    print output $fix . "  FETCH NEXT FROM \@clobs INTO \@lID;\n";
                    print output $fix . "  WHILE( \@\@FETCH_STATUS = 0 )\n";
                    print output $fix . "  BEGIN\n";
                    print output $fix . "    SELECT\n";
                    print output $fix . "      \@length = DataLength($column)\n";
                    print output $fix . "     ,\@ptrval = TEXTPTR($column) \n";
                    print output $fix . "     FROM $table\n";
                    print output $fix . "    WHERE $class" . "_ID = \@LID \n";
                    print output $fix . "\n";
                    print output $fix . "    UPDATETEXT $table.$column \@ptrval \@length 0 \@zero;\n";
                    print output $fix . "  \n";
                    print output $fix . "    FETCH NEXT FROM \@clobs INTO \@lID;\n";
                    print output $fix . "  END;-->WHILE<--\n";
                    print output $fix . "  CLOSE      \@clobs;\n";
                    print output $fix . "  DEALLOCATE \@clobs;\n";
                    print output $fix . "END;\n";
                    print output $fix . "GO\n";
                  }
              }
            elsif ( /CREATE TABLE B_([A-Za-z]+)_([A-Za-z]+)/ )
              {
                if ( $1 ne "WUser" )
                  {
                    #next;
                  }
                my $table = "B_$1_$2";
                my $class = $1;
                my $slot = $2;
                my $obj = $1;
                my $column = "W$2";

                if ( $slot eq "Desc" or $slot eq "Descrip" or $slot eq "Descripti" )
                  {
                    $column = "WDescription";
                  }
                if ( $class eq "WAnswer" )
                  {
                    $obj = "WAnswer_View";
                  }
                if ( $class eq "WMessage" )
                  {
                    $obj = "WMessage_View";
                  }
                print output "\n-- TABLE $table\n\n";

                # Missing rows in clob table
                #print output "SELECT '$table' AS WTable, (SELECT COUNT(1) FROM $obj) AS WObjCount, (SELECT COUNT(1) FROM $table) AS WClobCount FROM DUAL WHERE (SELECT COUNT(1) FROM $obj) <> (SELECT COUNT(1) FROM $table);\n";

                print output $count . "SELECT '$table' AS WTable, count(1), 'Missing' AS $column FROM $obj WHERE $class" . "_ID NOT IN (SELECT $class" . "_ID FROM $table);\n";

                print output $detail . "SELECT '$table' AS WTable, $class" . "_ID, 'Missing' AS $column FROM $obj WHERE $class" . "_ID NOT IN (SELECT $class" . "_ID FROM $table);\n";

                if ( $dbms eq "oracle" )
                  {
                    print output $fix . "INSERT INTO $table (SELECT $class" . "_ID, EMPTY_LOB() FROM $obj WHERE $class" . "_ID NOT IN (SELECT $class" . "_ID FROM $table));\n";
                  }
                else
                  {
                    print output $fix . "INSERT INTO $table (SELECT $class" . "_ID, NULL FROM $obj WHERE $class" . "_ID NOT IN (SELECT $class" . "_ID FROM $table));\n";
                  }
                print output $fix . "COMMIT;\n\n";

                if ( $dbms eq "oracle" )
                  {
                    print output $count . "SELECT '$table' AS WTable, count(1), 'NULL' AS $column FROM $table WHERE $column IS NULL;\n";

                    print output $detail . "SELECT '$table' AS WTable, $class" . "_ID, 'NULL' AS $column FROM $table WHERE $column IS NULL;\n";

                    print output $fix . "UPDATE $table SET $column = EMPTY_LOB() WHERE $column IS NULL;\n";
                    print output $fix . "COMMIT;\n\n\n";
                  }
              }
          }
        if ( $dbms eq "oracle" )
          {
            print output "\nSPOOL OFF\n";
          }
        close output;
      }
    close input;
  }

