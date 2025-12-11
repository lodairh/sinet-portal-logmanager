#!/usr/bin/perl
#
# SINET6ポータルの生ログを取得してログDB(sqlite3形式)に登録する。
# 　・生ログをそのままではなく、必要な分だけ抽出して登録する。
# 　・全てのログを登録はされていないので、不具合・障害等で参照する場合
# 　　最終的には生ログの方を参照すること。
# 　・ログファイルの日付指定はファイル名の日付を参照する。
# 　　つまりログファイルの作成された日を指定することになるので、
# 　　参照されるログは前日のログであることに注意。
# 2023.08.08 sasaki

use DBI;

# 引数 YYYYMMDD を渡すとその前日のログを抽出
$str = shift;

# ログDBファイルを置いてあるディレクトリ
$logdb_dir = '/home/common/portalreport_db';

# 生ログの置いてあるディレクトリ
$logdir = '/opt/apps/portal2022/log';

$conn = DBI->connect("dbi:SQLite:dbname=$logdb_dir/portalreport.db","","") or die print $DBI::errstr;
$report_insert = $conn->prepare("insert into portalreport_detail values (?,?,?,?,?)");
# 引数を指定しなかった場合は実行日の前日のログを参照する。
$time = time();
($sec, $min, $hour, $mday, $mon, $year, $wday) = localtime($time);
$y = $year+1900; $m = $mon+1; $d = $mday;

if ( $str eq '') {
  $date = sprintf "%04d%02d%02d", $y, $m, $d;
}
else {
  $date = $str;
}

# 指定した日時のファイル名のログファイルを参照し1行ずつ処理、
# 条件に一致した行からログを加工しログDBに登録。
open(LOG,"/usr/bin/gunzip -c $logdir/production.log-$date.gz|");
while(<LOG>) {
  # OTP success
  if ($_ =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):\d{2}.*user_id:\(guest\).*login: ((?:SI|SA|SB).*)\, otp_status: success/ ) {
    $report_insert->execute($1,$2,'OTPsend',$3,'0.0.0.0');
  }
  # OTP sendmail filed
  if ($_ =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):\d{2}.*user_id:\(guest\).*login: ((?:SI|SA|SB).*)\, otp_status: failure_not_found_user/ ) {
    $report_insert->execute($1,$2,'OTPnouser',$3,'0.0.0.0');
  }
  # TOP Page
  if ($_ =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):\d{2}.*user_id:\{\"login\":\"((?:SI|SA|SB).*)\"\}.*Started GET \"\/\" for (.*) at/ ) {
    $report_insert->execute($1,$2,'top',$3,$4);
  }
  # Login record
  if ($_ =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):\d{2}.*user_id:\{\"login\":\"((?:SI|SA|SB).*)\"\}.*Started GET \"\/login_sessions\" for (.*) at/ ) {
    $report_insert->execute($1,$2,'login_sessions',$3,$4);
  }
  # physical connections
  if ($_ =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):\d{2}.*user_id:\{\"login\":\"((?:SI|SA|SB).*)\"\}.*Started GET \"\/physical_connections\" for (.*) at/ ) {
    $report_insert->execute($1,$2,'physical',$3,$4);
  }
  # user services
  if ($_ =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):\d{2}.*user_id:\{\"login\":\"((?:SI|SA|SB).*)\"\}.*Started GET \"\/use_services\" for (.*) at/ ) {
    $report_insert->execute($1,$2,'services',$3,$4);
  }
  # Account data
  if ($_ =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):\d{2}.*user_id:\{\"login\":\"((?:SI|SA|SB).*)\"\}.*Started GET \"\/account\" for (.*) at/ ) {
    $report_insert->execute($1,$2,'account',$3,$4);
  }
  # Org data
  if ($_ =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):\d{2}.*user_id:\{\"login\":\"((?:SI|SA|SB).*)\"\}.*Started GET \"\/account\/org\" for (.*) at/ ) {
    $report_insert->execute($1,$2,'org',$3,$4);
  }
  # Application data
  if ($_ =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):\d{2}.*user_id:\{\"login\":\"((?:SI|SA|SB).*)\"\}.*Started GET \"\/application_forms\" for (.*) at/ ) {
    $report_insert->execute($1,$2,'application',$3,$4);
  }
  # Link Page
  if ($_ =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):\d{2}.*user_id:\{\"login\":\"((?:SI|SA|SB).*)\"\}.*Started GET \"\/links\" for (.*) at/ ) {
    $report_insert->execute($1,$2,'links',$3,$4);
  }
  # (ADMIN) User admin
  if ($_ =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):\d{2}.*user_id:\{\"login\":\"((?:SI|SA|SB).*)\"\}.*Started GET \"\/users\" for (.*) at/ ) {
    $report_insert->execute($1,$2,'adm_users',$3,$4);
  }
  # (ADMIN) GAKUNIN
  if ($_ =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):\d{2}.*user_id:\{\"login\":\"((?:SI|SA|SB).*)\"\}.*Started GET \"\/shibboleth_mappings\" for (.*) at/ ) {
    $report_insert->execute($1,$2,'adm_gakunin',$3,$4);
  }
  # (ADMIN) Page Editor
  if ($_ =~ /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):\d{2}.*user_id:\{\"login\":\"((?:SI|SA|SB).*)\"\}.*Started GET \"\/settings\/edit\" for (.*) at/ ) {
    $report_insert->execute($1,$2,'adm_editor',$3,$4);
  }
}
