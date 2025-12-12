# sinet-portal-logmanager

## 概要
SINET ポータルの標準には、ログ統計を行い表示する機能が無いので、ポータルが出力する生 log データを Perl スクリプトで加工して、それを統計データとして Perl CGI で Web 表示させる機能を提供する。

## 機能
- admin/report：Web CGI 機能
  - tools/report にあるツールで取得したログデータを元に、Web 表示する CGI スクリプト群
- tools/report：ログ取得、加工機能
  - SINET ポータルの生 log データを参照し、使いやすい形に加工して統計用のデータベースに格納するツール群

## 補足
それぞれの詳細はそれぞれのフォルダの README を参照のこと。
