#Mikasa Recommend System


## インストール

``bundle install``

## 事前準備

* Kafka起動
* mikasa_olを起動
* HTTP Serverを起動
* cp config/application.json.sample config/application.jsonを実行し設定を記述

## プログラム起動


### mikasa_view

#### 概要

Twitterで呟かれているトレンドタイトルをつぶやきアニメビッグデータっぽく表示する

#### 準備

```
mkdir /usr/share/nginx/html/5
mkdir /usr/share/nginx/html/60
cp sample/* /usr/share/nginx/html/5/
cp sample/* /usr/share/nginx/html/60/
```

``bundle exec ruby mikasa_view.rb [Kafka TOPIC] [every_minute]``

every_minuteはディレクトリ名、ファイル名などの識別子に使用

直近5分の集計を毎分受信

``bundle exec ruby mikasa_view.rb ikazuchi0.view 5``

直近60分の集計を毎分受信

``bundle exec ruby mikasa_view.rb ikazuchi0 60``

### mikasa

#### 概要

Twitterで呟かれているトレンドタイトルをアマゾンで検索しお薦め商品としてツイートするボット

Crontabで１時間に１度起動する想定（1時間に40ツイート）

``bundle exec ruby mikasa.rb [Kafka TOPIC]``

``bundle exec ruby mikasa.rb [ikazuchi0]``

#### wheneverを使ってcronに設定する

```
./setup.sh
```

```
vi ./config/schedule.rb
```

もしくはコピーして編集する

```
mkdir private
cp /config/schedule.rb private/schedule_hogehoge.rb
```

cronに登録

```
whenever -f private/schedule_hogehoge.rb
```

上記で出力された設定をcrontabにコピーする

crontabを全上書きしたい場合は以下

```
whenever -w -f private/schedule.rb
```
