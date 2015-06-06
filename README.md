#Mikasa Recommend System


## インストール

``bundle install``

## 事前準備

* Kafka起動
* mikasa_olを起動
* HTTP Serverを起動
* cp config/applocation.json.sample config/applocation.jsonを実行し設定を記述

## プログラム起動

``bundle exec ruby mikasa_view.rb [Kafka TPIC] [every_minute]``

every_minuteはディレクト名、ファイル名などの識別子に使用

``bundle exec ruby mikasa_view.rb ikazuchi0.view 3``
