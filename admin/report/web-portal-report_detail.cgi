#!/usr/bin/perl
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI qw/:standard/;
use DBI;

$logdb_dir = '/home/common/portalreport_db';

$conn = DBI->connect("dbi:SQLite:dbname=$logdb_dir/portalreport.db","","") or die print $DBI::errstr;
$sth_detail = $conn->prepare("select * from portalreport_detail where date = ? and not userid like \'SI-%\'");

%page = ('top','TOPページ',
         'OTPsend','OTP発行',
         'OTPnouser','OTP送付先不明',
         'login_sessions','ログイン記録',
         'physical','物理接続状況',
         'services','利用サービス状況',
         'account','個人情報',
         'org','機関情報',
         'application','申請状況',
         'links','FAQ・リンク',
         'adm_user','ユーザー管理（サイト管理者用）',
         'adm_gakunin','学認連携設定管理（サイト管理者用）',
         'adm_editor','利用ポータル表示内容編集（サイト管理者用）',
         'personal_menu','個人情報'
 );

  $date = param('date');
print header(-type=>'text/html',-charset=>'UTF-8'),
      start_html(-lang=>'ja',
                 -title=>"$date 詳細",
                 -style=>{'src'=>'/css/eduroam.css'},
                 -head=>meta({'http-equiv'=>'Content-Type',
                              'content'=>'text/html; charset=utf8'}));

  $sth_detail->execute($date);
  $detail = $sth_detail->fetchall_arrayref;

  print h3("$date 詳細");

  print a({-href=>'/admin/report/web-portal-report.cgi'},'戻る');
  print table({-border=>undef});
  print Tr([
        th(['年月日','時刻','アクセス先ページ','アカウント名','アクセス元IP'])
          ]);
  foreach $i ( @{$detail} ) {
    print Tr([
        td([$i->[0],$i->[1],$page{"$i->[2]"},$i->[3],$i->[4]])
          ]);
  }
  print '</TABLE>';
  print a({-href=>'/admin/report/web-portal-report.cgi'},'戻る');

print hr;
print end_html;
