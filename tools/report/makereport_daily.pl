#!/usr/bin/perl
#
# ログDBに登録されている加工ログから、毎日統計を取得する。
# 　・各ページアクセス数はその日にアクセスのあった累計数
# 　・user は、その日にアクセスのあったユニークなID数。
# 　　同じアカウントが同じ日に何度もアクセスしても、
# 　　そのアカウントのアクセス数は1回と数える。
# 2023.08.08 sasaki

use DBI;

# 引数 YYYY-MM-DD でその日のログを対象に集計する。
$str = shift;
$logdb_dir = '/home/common/portalreport_db';

$conn = DBI->connect("dbi:SQLite:dbname=$logdb_dir/portalreport.db","","") or die print $DBI::errstr;
$dailyreport = $conn->prepare("select * from portalreport_detail where date = ? and not userid like \'%SI-%\'");
$daily = $conn->prepare("insert into portalreport values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");

# 引数を指定しなかった場合、実行日の前日のログを集計する。
$time = time() - 24 * 3600;
($sec, $min, $hour, $mday, $mon, $year, $wday) = localtime($time);
$y = $year+1900; $m = $mon+1; $d = $mday;

if ( $str eq '') {
  $date = sprintf "%04d-%02d-%02d", $y, $m, $d;
}
else {
  $date = $str;
}

# ログDBから指定した日のログを取得
$dailyreport->execute($date);
$ref_report = $dailyreport->fetchall_arrayref;

$users = 0;
%access = 0;
undef %user;

# 取得したログを1行ずつ処理、統計を取る。
foreach $i ( @$ref_report ) {
  # 各ページのアクセス数をそのまま合計する。
  $access{$i->[2]}++;
  # ユーザー数は、ログイン後のトップページにアクセスしたアカウントだけを対象に、
  # まだ一度も出現していないアカウントだった場合は
  # その日のユーザー数に＋１した上で連想配列名として登録する。
  # 連想配列名として登録済みのアカウントだった場合は何もしない（集計しない）。
  if( $i->[2] eq 'top' ) {
    unless( defined $user{$i->[3]} ) {
      $users++;
      $user{$i->[3]} = 1;
    }
  }
}

# 指定した日の分のログを全部処理し終わったら、集計したデータをDBに登録する。
$daily->execute($date,$users,$access{'OTPsend'},$access{'OTPnouser'},$access{'top'},$access{'login_sessions'},$access{'physical'},$access{'services'},$access{'account'},$access{'org'},$access{'application'},$access{'links'},$access{'adm_users'},$access{'adm_gakunin'},$access{'adm_editor'});
