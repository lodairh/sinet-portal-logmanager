# admin/report

## 概要
- ここにある CGI スクリプトは、`https://[サイトホスト名]/admin/[スクリプト名]` にアクセスすると Web ページとして参照できる位置に配置されることを想定しているので、Web サーバの httpd.conf 等を確認し、場合によっては設定を変更しつつ配置する。
- tools/report の CGI スクリプトとデータベースを共有するので、コード内の $log_dir に設定されているデータベースへの PATH を tools/repoot のそれと一致させる必要がある。

## ファイル
- web-portal-report.cgi
  - ログ統計ページのTOPページ
  - 日毎の統計を表示する
- web-portal-report_detail.cgi
  - 日毎の統計を表示する
  - web-portal-report.cgi で、特定の日付のボタンをクリックすると、その日の統計の内訳を表示する
