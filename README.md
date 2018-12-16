# Tipping-for-Runner

## フロントエンド
#### Androidアプリケーション開発

#### LINEのログインAPIでログイン

#### LINEのBotをRUNNERが作成するのを支援

#### マラソンランナーの一覧表示(サーバのAPIをたたいて取得とか)

#### スマホのフリフリを感知して、ユーザのログイン情報を持ったままBotへ数値の「1」を送信

## バックエンド

#### フリフリがあってBotに情報が送信されたときにその情報を特定のRUNNERの応援としてカウント

#### DB等にどのランナーに対してどれだけの応援がされたかを保持。

#### マラソンが終わったときにRUNNERにどれだけの応援がなされたか通知が行く。

## 環境構築(sinatra + ActiveRecord)

Rubyをインストール後、作業ディレクトリに移動し以下のコマンドを実行

```
$ cd src
$ gem install bundler
$ bundle without --production #Gemfileをもとに必要なgemをインストール
```
### ActiveRecordのモデルを作成する
## Rakefileの作成〜DBのマイグレーション

rakefileの作成(作成済み)

```
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
```

これでrakeコマンドが使用可能になる

ターミナルにて以下のコマンドを入力
NAME=create_~~~にはテーブル名(複数形)を指定

```
$ bundle exec rake db:create_migration NAME=create_tests
db/migrate/20181101082310_create_tests.rb
```

実行すると``db/migrate/20181101082310_create_tests.rb``のようなファイルが作成される

作成されたファイルを以下のように編集
string型のtitle, string型のcontentカラムが生成される
テーブル名はtests

```
class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.string :title
      t.string :content
      t.timestamps
    end
  end
end
```

``models/post.rb``というファイルを作って、以下のように書く。
先ほどのテーブルがtestsなので、モデル名はTestと単数形になる

```
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class Test < ActiveRecord::Base
end
```

Rakefileも編集しておく。 models/test.rb を読み込んで、rakeコマンドでDBと接続できるようにする。

```
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require './models/test.rb'
```

これでDBとの接続は完了する。
ターミナルで以下のコマンドを叩くとテーブルが
migrationファイルをもとに自動生成される

```
$ bundle exec rake db:migrate
== 20181101082310 CreateTests: migrating ======================================
-- create_table(:tests)
DEPRECATION WARNING: `#timestamps` was called without specifying an option for `null`. In Rails 5, this behavior will change to `null: false`. You should manually specify `null: true` to prevent the behavior of your existing migrations from changing. (called from block in change at /Users/lab-admin/Tipping-for-Runner/backend/src/db/migrate/20181101082310_create_tests.rb:6)
   -> 0.0011s
== 20181101082310 CreateTests: migrated (0.0012s) =============================
```

bot友達追加時にrunner or audienceボタン 
ランナーですとメッセージが来るとランナーdbにrunner_line_idが登録される
観客ですとメッセージが来ると観客dbにaudience_line_idが登録される
特定のidから特定のidにメッセージが送信される

## API設計

### hostname
tipping-for-runner

# Group ユーザ
 
## ユーザのエンドポイント [/marathon]
 
### マラソン情報取得 [GET]
 
#### 処理概要
 
* マラソンの情報を取得
 
+ Response 200 (application/json)
 
    + Attributes
        + id: 1 (integer, required) - id
        + name: 大阪マラソン (string, required) - 名前

### ランナー操作
・post /runner/:id

# Group　runner
 
## runnerのエンドポイント [/runner]
 
### runner登録 [POST]
 
#### 処理概要

* ランナーが出場するレースを選択し登録する
* 登録に成功した場合、201を返す。
 
+ Request (application/json)
 
    + Headers
 
            Accept: application/json
 
    + Attributes
        + maker_name: Apple, Samsung (string, required) -  メーカー名
        + category: iPhone X (string, required) - 機種名
        + data_capacity: 128 (integer, required) - データ容量 
        + date: 2018-12-28 (DATE, required) - 発売日
        + os_version:　(string, required) - OSバージョン
        + color: red (string, required) - 色
        + price: 98000 (integer, required) - 販売価格
+ Response 201 (application/json)

# Group　ユーザ
 
## ユーザのエンドポイント [/runners/:marathonId]
 
### 指定したmarathonのrunnerを返す [POST]
 
#### 処理概要

* 指定したレースの参加ランナーを返す
 
+ Request (application/json)
 
    + Parameter
        + marathonId: 2 (integer, required) - マラソン番号
        
+ Response 200 (application/json)
 
    + Attributes
        + id: 1 (integer, required) - id
        + name: ベンチャー (string, required) - ランナーの名前
        + number: 1 (integer, required) - ゼッケン番号
        + marathon_id: 2 (integer, required) - マラソン番号
        + line_user_id: fiohviojv (string, required) - ランナーのラインユーザーid
        
# Group　ユーザ
 
## ユーザのエンドポイント [/line/push/:runnerId]
 
### 指定したrunnerに応援を送る [POST]
 
#### 処理概要

* idは指定したランナーのユーザーid
* 観客は応援したいランナーを選択してシェイク
* bodyにシェイク回数、audience_line_idを格納
* 返り値としてランナーに応援が通知される
 
+ Request (application/json)
 
    + Parameter
        + runnerId: 1(integer, required) - ランナーのユーザid
    
    + Headers

            Accept: application/json
        
    
    + Attributes
        + number: 5 (integer, required) - シェイク回数
        + audience_line_id: fhwejvnvj (string, required) - 観客のラインユーザID
        
+ Response 201 (application/json)
 


### 観客操作
・post /runners/:id
idはマラソンのidを指定
指定したレースの参加ランナーを返す

・post /line/push/:id
idは指定したランナーのユーザーid
観客は応援したいランナーを選択してシェイク
bodyにシェイク回数、audience_line_idを格納
返り値としてランナーに応援が通知される

### bot動作
テキストで

/linepay
観客にシェイクした回数分のお金を決済するためのurlを送付

## DB設計

### marathon

|marathon_id  | Right align  |
|:-----------:|:------------:|
|int       PRI|varchar       | 
