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

## DB設計

### marathon

|marathon_id  | Right align  |
|:-----------:|:------------:|
|int       PRI|varchar       | 
