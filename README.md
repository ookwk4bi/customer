# README

<br>
  
  
# アプリケーション名
スクレイピングツール

<br>
  

# アプリケーション概要
【概要】<br>
このアプリケーションは、非同期処理による自動でスクレイピングを行います。以下に、主な機能を説明します。<br>

①スクレイピング機能<br>
顧客情報を登録する際には、常連様や対応に注意が必要な顧客などのカテゴリーを選択し、詳細にその顧客の適切な対応方法や注意事項を記載します。<br>これにより、顧客ごとに異なる対応が必要な場合でも、適切に対応することができます。

②CSVインポート機能<br>
当日に利用されるお客様の情報を、CSVインポート機能を使ってアプリケーションに取り込むことができます。<br>
これにより、手動で顧客情報を入力する手間を省くことができます。

③一括検索とCSVエクスポート機能<br>
アプリケーションに取り込んだ全ての顧客情報をコピーし、検索機能に添付します。<br>ボタンをクリックすることで、適切な対応や注意事項がある顧客を一括検索し、CSVファイルを作成しダウンロードすることができます。<br>この機能により、顧客情報を一元管理し、迅速かつ正確な情報の提供が可能となります。
<br>

【アプリケーションを作成した背景】<br>
特別な顧客対応が必要な顧客を事前に認知し、従業員の対応の間違いやクレームに発展しないようにします。顧客満足度を上げることが目的です。<br>
1日あたり100人規模の対応が必要な現場では、事前に特別な対応が必要なお客様を認知することが困難であり、クレームや問題に発展するケースが多発しています。<br>このような状況から、アプリケーションを利用して事前に特別対応が必要なお客様をピックアップし、適切な対応を行うことで顧客満足度向上に貢献できると考えました。<br>




<br>

# URL 

#### 【デプロイ】
・スクレイピング機能のため、本番環境でデプロイはしておりません。

# 利用方法
* GitHubにて登録してあるCSVファイルをDownload ZIPして活用ください。（Codeボタン押下→Download ZIPボタンを押下→csv_data.csvファイルをダウンロード。）

* Chromeの最新版を利用してアクセスしてください。

* テストアカウントでログイン→トップページから【顧客登録】ボタン押下。

* 顧客情報入力→【登録】ボタン押下。

* トップページの一覧ページに顧客情報が登録。

* 一覧ページリンク欄の【詳細】ボタンを押下→詳細ページに遷移→顧客情報の編集・削除・コメント・評価の機能を実装しています。

* トップページ→【CSVデーター】ボタン押下→CSVインポートの機能ページへ遷移。

* 【ファイルを選択】ボタンを押下→CSVファイルを選択→【インポート】ボタンを押下→アプリケーションに顧客情報が取り込まれます。

* CSVインポートの機能ページ→一覧ページに表示された利用予定の顧客情報を全てコピー。(1回に100名の情報まで)

* トップページの検索機能に全ての顧客情報を貼り付け→【CSVデーター出力】ボタンを押下→顧客情報を一括検索し、CSVファイルが作成され、ダウンロードが可能です。

* 特別対応の必要な顧客情報が一覧ページに表示されます。


<br>



# 洗い出した案件
[案件を定義したシート](https://docs.google.com/spreadsheets/d/1uVg2ICpejKJ08BUCTV34auy97JGyp0MfRH5QQo4UIIQ/edit#gid=982722306)

<br>


# メイン機能

<br>
  

## 1.トップページ
スクレイピングの実行後のCSVファイルの一覧ページ。（CSVファイルのダウンロードも可能）

<br>

[![Image from Gyazo](https://i.gyazo.com/fd420ee38181019a66bb08b8519b27a2.gif)](https://gyazo.com/fd420ee38181019a66bb08b8519b27a2)

<br>

## 2.スクレイピング機能
sidekiqによる非同期処理でスクレイピングの処理を実行し、データーを収集します。<br>
スクレイピング終了後はCSVファイルが作成され、一覧ページに自動的に添付。CSVファイルのダウンロードが可能です。

<br>

[![Image from Gyazo](https://i.gyazo.com/4edb5b78a34c00a271e375c2ab414dd7.gif)](https://gyazo.com/4edb5b78a34c00a271e375c2ab414dd7)

<br>

[![Image from Gyazo](https://i.gyazo.com/43033a938c92e5072de3c2d08ac3310e.gif)](https://gyazo.com/43033a938c92e5072de3c2d08ac3310e)

<br>

[![Image from Gyazo](https://i.gyazo.com/912bd6f52911282e4f3fe55ea6b87870.gif)](https://gyazo.com/912bd6f52911282e4f3fe55ea6b87870)



<br>

# 実装した機能

<br>

## １.ユーザー管理機能
ユーザーの登録が可能です。
<br>

[![Image from Gyazo](https://i.gyazo.com/9dc5e8f1e106a5e495282894455e3577.gif)](https://gyazo.com/9dc5e8f1e106a5e495282894455e3577)

<br>


## 2.会社情報登録
姓・名・詳細・会員番号・カテゴリーの顧客情報を入力し、顧客の適切な対応方法や注意事項を記載します。顧客情報の登録が可能です。

<br>

[![Image from Gyazo](https://i.gyazo.com/8ea385e883c1043dfd51e00bb534e3a7.gif)](https://gyazo.com/8ea385e883c1043dfd51e00bb534e3a7)

<br>

## 3.CSVエクポート機能
登録した会社情報の閲覧が可能です。<br>
顧客の編集・削除・コメント・評価の機能が実装しています。

<br>

[![Image from Gyazo](https://i.gyazo.com/6d347993156a7762f93ea9901ceb17ac.gif)](https://gyazo.com/6d347993156a7762f93ea9901ceb17ac)

<br>

## 4.編集機能
登録した顧客情報について、編集することができます。<br>
ユーザーの手間を省くため登録時の情報が表示されます。

<br>

[![Image from Gyazo](https://i.gyazo.com/a03070f210920f6db2840461c2d58956.gif)](https://gyazo.com/a03070f210920f6db2840461c2d58956)
<br>

## 5.削除機能
登録した顧客情報の削除ができます。<br>
削除時は確認のアラートが表示します。


<br>

[![Image from Gyazo](https://i.gyazo.com/3f9a0840aa75b88bb2fe0b10273962c7.gif)](https://gyazo.com/3f9a0840aa75b88bb2fe0b10273962c7)

<br>

## 6.検索機能
登録した顧客情報についてより詳しい詳細を残すこができます。(出来事・対応など)

<br>

[![Image from Gyazo](https://i.gyazo.com/f348e6ce39825aac02fc2558a48837be.gif)](https://gyazo.com/f348e6ce39825aac02fc2558a48837be)

<br>

## 6.Basic認証機能
登録した顧客情報についてより詳しい詳細を残すこができます。(出来事・対応など)

<br>

[![Image from Gyazo](https://i.gyazo.com/a1216165b58405c00daf464166beb224.gif)](https://gyazo.com/a1216165b58405c00daf464166beb224)


# テーブル設計

<br>

## users テーブル

| Column             | Type   | Options     
| ------------------ | ------ | ----------- 
| email              | string | null: false 
| encrypted_password | string | null: false 

<br>

## company テーブル

| Column             | Type   | Options     
| ------------------ | ------ | ----------- 
| name              | string | null: false 
| adress            | text   | null: false 
| url               | text   | null: false 
| user              | references | null: false, foreign_key: true 
<br>

## scraping テーブル

| Column             | Type   | Options     
| ------------------ | ------ | ----------- 
| name         | string | null: false 
| url          | text | null: false 
| user         | references | null: false, foreign_key: true 

## Kewords テーブル

| Column             | Type   | Options     
| ------------------ | ------ | ----------- 
| open_filename          | string | null: false 
| save_failenam          | string | null: false 
| user                   | references | null: false, foreign_key: true 
  

<br>


# ER図
[![Image from Gyazo](https://i.gyazo.com/3228eff4ba223f850bbe8295879eb065.gif)](https://gyazo.com/3228eff4ba223f850bbe8295879eb065)<br>
<br>

# 開発環境
Ruby/Ruby on Rails/JavaScript/MySQL/Github/Visual Studio Code<br>
<br>

# ローカルでの動作方法 

```bash
$ git@github.com:ookwk4bi/customer.git
``` 

```bash
$ cd customer
``` 

```bash
$ bundle install
``` 

```bash
$ rails db:create
``` 

```bash
$ rails db:migrate
``` 

```bash
$ yarn install　
``` 

<br>

# 工夫したポイント
*  CSVインポートやCSVエクスポートのCSVファイルを活用した実装。

*  JavaScriptを活用した段階評価のコメント機能を実装。

*  CSVエクスポートと一括検索を併用したCSVファイルの作成・ダウンロードの機能の実装。

*  検索機能を複数条件で検索できるように実装

*  使ったことのなかったgemを多く使用した。








