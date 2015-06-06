#Mikasa Recommend System


## インストール

``bundle install``

## 事前準備

* Kafka起動
* mikasa_olを起動
* HTTP Serverを起動
* cp config/applocation.json.sample config/applocation.jsonを実行し設定を記述

## プログラム起動

``bundle exec ruby mikasa_view.rb [Kafka TOPIC] [every_minute]``

every_minuteはディレクトリ名、ファイル名などの識別子に使用

直近5分の集計を毎分受信

``bundle exec ruby mikasa_view.rb ikazuchi0.view 5``

直近60分の集計を毎分受信

``bundle exec ruby mikasa_view.rb ikazuchi0 60``