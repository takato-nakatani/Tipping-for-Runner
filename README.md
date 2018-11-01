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
