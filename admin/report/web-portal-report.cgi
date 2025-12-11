#!/bin/perl
#
# 2023.08.09 sasaki
#
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI qw/:standard/;
use DBI;

$logdb_dir = '/home/common/portalreport_db';

print header(-charset=>'utf-8'),
        start_html(-title=>'SINET6ポータルアクセス統計',
                   -BGCOLOR=>'white'),
        h3('SINET6ポータルアクセス統計');

my $ip = $ENV{'REMOTE_ADDR'};
unless(
       $ip =~ /^136.187.(?:(232|234|235))/
      ) {
  print "あなたがアクセスしている端末のIPアドレス: $ip\n",br,br;
  print 'このページは、所内の一部端末からのみ閲覧可に設定されています。',hr;
  print 'SINET利用ポータル担当',address('portal-inquiry [at] sinet.ad.jp');
  exit 0;
}

$conn = DBI->connect("dbi:SQLite:dbname=$logdb_dir/portalreport.db","","") or die print $DBI::errstr;
$basedata = $conn->selectall_arrayref("select * from portalreport order by date");

  print ul([
          li(['その日の各ページへのアクセス数累計',
              'ユニークユーザー数：その日にアクセスのあったアカウントID名別の集計。同じIDで複数回アクセスがあっても１回
で集計する。'])
        ]);
  print start_form(-method=>'post',-action=>'/admin/report/web-portal-report_detail.cgi');

  print table({-style=>'font-size : 15px', -border=>1});
  print Tr([
            th(["日付","ユニークユーザー数","ワンパス発行数","TOP","ログイン記録","物理状況","サービス状況","個人","機関","申請状況","FAQリンク"]),
            ]);

  for $i ( @{$basedata} ) {
      print Tr([
              td({align=>'right'},[submit(-name=>'date',-value=>$i->[0]),$i->[1],$i->[2],$i->[4],$i->[5],$i->[6],$i->[7],$i->[8],$i->[9],$i->[10],$i->[11]]),
              ]);
  }
  print "</TABLE>",
  end_form,hr;
  print 'SINET利用ポータル担当',address('portal-inquiry [at] sinet.ad.jp');

print end_html;
