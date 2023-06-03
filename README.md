# README

<br>
  
  
# アプリケーション名
スクレイピングツール

<br>
  

# アプリケーション概要
【概要】<br>
このアプリケーションは、非同期処理・並列処理による自動でスクレイピングを行います。<br>以下に、主な機能を説明します。<br>

①スクレイピング機能<br>
このアプリケーションは、CSVファイル名と対応するWEBサイトのURLを登録することで、スクレイピングの処理を実行します。<br>
スクレイピングが実行されると、SidekiqとRedisが非同期処理を行い、WEBサイトから会社名、住所、URLの情報を取得します。
<br>
取得した情報をもとにCSVファイルが作成され、一覧ページにCSVファイルが添付されます。また、CSVファイルをダウンロードすることも可能です。
<br>
このアプリケーションを使用することで、簡単かつ自動的にWEBサイトから情報を取得し、CSVファイルとして保存することができます。
<br>
Sidekiqの並列処理機能を活用して、複数のWebサイトから同時にデータを収集することもできます。
<br>

②営業先の会社情報の管理<br>
会社名・住所・URLの営業先の会社情報を登録し、管理することができます。<br>
CSVエクポートのボタンを押すことでCSVファイルとして会社情報が出力されます。<br>


【アプリケーションを作成した背景】<br>
営業部門でのSEO営業において、毎日100件以上の営業電話を行っていました。<br>
しかし、営業先の電話番号やサイトURLを手動で収集した上で、営業先のWEBサイトを調査し、営業の連絡を取るという作業には時間と手間がかかっていました。<br>
そこで私は、社内ツールとして、営業先の会社情報をよく収集しているWEBサイトの会社情報を自動で取得するスクレイピングツールを開発しました。営業先の情報収集作業を効率化し、自社の業務改善につなげようと考えました。




<br>

# URL 

#### 【デプロイ】
・スクレイピング機能のため、本番環境でデプロイはしておりません。


<br>

<!-- # 洗い出した案件
[案件を定義したシート](https://docs.google.com/spreadsheets/d/1uVg2ICpejKJ08BUCTV34auy97JGyp0MfRH5QQo4UIIQ/edit#gid=982722306) -->

<br>


# メイン機能

<br>
  

## 1.会社情報一覧ページ
営業先の会社情報の一覧ページです。<br>
会社情報の登録とCSVファイルの出力が可能です。

<br>

[![Image from Gyazo](https://i.gyazo.com/0a4d7cb0c2779e633584a2f9a45f32f1.gif)](https://gyazo.com/0a4d7cb0c2779e633584a2f9a45f32f1)

<br>

## 2.スクレイピング機能
①登録ページにて保存するファイル名とサイトURLを入力し、スクレイピング処理を実行。<br>
(バリデーションの処理で他のサイトのURLは登録できません。)<br>
SidekiqとRedisが非同期処理を行い、WEBサイトから会社名、住所、URLの情報を取得します。

<br>

[![Image from Gyazo](https://i.gyazo.com/4edb5b78a34c00a271e375c2ab414dd7.gif)](https://gyazo.com/4edb5b78a34c00a271e375c2ab414dd7)


<br>

[![Image from Gyazo](https://i.gyazo.com/43033a938c92e5072de3c2d08ac3310e.gif)](https://gyazo.com/43033a938c92e5072de3c2d08ac3310e)

<br>
②スクレイピング処理後にCSVファイルが作成され、一覧ページにCSVファイルが添付されます。
<br>CSVファイルをダウンロードすることも可能です。

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


## 2.会社情報の登録
会社名・住所・サイトURLを登録することができます。<br>営業先の会社情報を管理する目的があります。

<br>

[![Image from Gyazo](https://i.gyazo.com/8ea385e883c1043dfd51e00bb534e3a7.gif)](https://gyazo.com/8ea385e883c1043dfd51e00bb534e3a7)

<br>

## 3.CSVエクポート機能
管理している営業先の会社情報をCSVファイルとして出力することできます。

<br>

[![Image from Gyazo](https://i.gyazo.com/6d347993156a7762f93ea9901ceb17ac.gif)](https://gyazo.com/6d347993156a7762f93ea9901ceb17ac)

<br>

## 4.編集機能
登録した会社情報の編集がきます。<br>
【スクレイピング機能】：ファイル名・URLの編集。<br>
【営業先の会社登録】：会社名・住所・URLの編集。


<br>

[![Image from Gyazo](https://i.gyazo.com/a03070f210920f6db2840461c2d58956.gif)](https://gyazo.com/a03070f210920f6db2840461c2d58956)
<br>

## 5.削除機能
登録した会社情報の削除ができます。<br>
削除時は確認のアラートが表示します。


<br>

[![Image from Gyazo](https://i.gyazo.com/3f9a0840aa75b88bb2fe0b10273962c7.gif)](https://gyazo.com/3f9a0840aa75b88bb2fe0b10273962c7)

<br>

## 6.検索機能
【スクレイピング機能】タイトルとURLで検索可能。<br>
【営業先の会社登録】会社名・住所・URLで検索可能<br>


<br>

[![Image from Gyazo](https://i.gyazo.com/f348e6ce39825aac02fc2558a48837be.gif)](https://gyazo.com/f348e6ce39825aac02fc2558a48837be)

<br>

## 6.Basic認証機能
アクセスを許可されたユーザーのみがウェブサイトやWebアプリケーションにアクセスできるようになります。

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
| save_filename          | string | null: false 
| user                   | references | null: false, foreign_key: true 
  

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
*  SidekiqとActive Jobの機能を使い、スクレイピングの非同期処理と並列処理の実装。

*  CSVエクスポート機能とCSVファイルのダウンロード機能の実装。

*  検索機能を複数条件で検索できるように実装

*  ドロップダウンメニューの実装。










