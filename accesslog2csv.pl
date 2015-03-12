#!/usr/bin/perl

# 
# @file
# Converter tool, from Apache Common Log file to CSV.
# 
# All code is released under the GNU General Public License.
# See COPYRIGHT.txt and LICENSE.txt.
#

if ("$ARGV[0]" =~ /^-h|--help$/) {
  print "Usage: $0 access_log_file > csv_output_file.csv\n";
  print "   Or, $0 < access_log_file > csv_output_file.csv\n";
  print "   Or, $0 < access_log_file > csv_output_file.csv 2> invalid_lines.txt\n";
  exit(0);
}

%MONTHS = ( 'Jan' => '01', 'Feb' => '02', 'Mar' => '03', 'Apr' => '04', 'May' => '05', 'Jun' => '06',
  'Jul' => '07', 'Aug' => '08', 'Sep' => '09', 'Oct' => '10', 'Nov' => '11', 'Dec' => '12' );

print STDOUT "\"Host\",\"Log Name\",\"Date Time\",\"Time Zone\",\"Method\",\"URL\",\"Response Code\",\"Response Body\",\"Processing Time\"\n";
$line_no = 0;

while (<>) {
  ++$line_no;
  
  $line = $_;
  $line =~ s/\s\?/?/;
  
  if ($line =~ /^([\w\.:-]+)\s+([\w\.:-]+)\s+([\w\.-]+)\s+\[(\d+)\/(\w+)\/(\d+):(\d+):(\d+):(\d+)\s?([\w:\+-]+)]\s+"(\w+)\s+(\S+)\s+HTTP\/1\.\d"\s+(.*)/) {
    $host = $1;
    $other = $2;
    $logname = $3;
    $day = $4;
    $month = $MONTHS{$5};
    $year = $6;
    $hour = $7;
    $min = $8;
    $sec = $9;
    $tz = $10;
    $method = $11;
    $url = $12;
    
    $tmp = $13;
    print "tmp = \"$tmp\"\n";
    my $code = 0;
    my $byters = 0;
    my $ptime = 0;
    if ( $tmp =~ /^(\d+)\s+([\d-]+)\s?$/ ){
        $code = $1;
        if ($14 eq '-') {
          $byters = 0;
        } else {
          $byters = $2;
        }
    } elsif ( $tmp =~ /^(\d+)\s+([\d-]+)\s+([\d-]+)\s?$/ ){
        $code = $1;
        if ($14 eq '-') {
          $byters = 0;
        } else {
          $byters = $2;
        }
        $ptime = $3;
    }

    print STDOUT "\"$host\",\"$logname\",\"$year-$month-$day $hour:$min:$sec\",\"GMT$tz\",\"$method\",\"$url\",$code,$byters,$ptime\n";
  } else {
    print STDERR "Invalid Line at $line_no: $_";
  }
}
