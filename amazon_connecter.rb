require 'amazon/ecs'
require 'json'

## Amazon API 1時間につき2,000リクエスト

class AmazonConnecter

  File.open './config/application.json' do |file|
    conf = JSON.load(file.read)
    @amazon_conf = conf["Amazon"]
  end

  Amazon::Ecs.options = {
      :associate_tag => @amazon_conf["associate_tag"],
      :AWS_access_key_id => @amazon_conf["AWS_access_key_id"],
      :AWS_secret_key => @amazon_conf["AWS_secret_key"]
  }

  # タイトルのリストを受け取り 10件ずつ商品のリストを返す
  # https://images-na.ssl-images-amazon.com/images/G/09/associates/paapi/dg/index.html?ItemSearch.html
  # ItemSearch は、一度に最大で10個の検索結果を返します。
  def search(title)
    # sort param
    # https://images-na.ssl-images-amazon.com/images/G/09/associates/paapi/dg/index.html?APPNDX_SortValuesArticle.html
    # JA SORT
    # https://images-na.ssl-images-amazon.com/images/G/09/associates/paapi/dg/index.html?APPNDX_SortValuesArticle.html
    # SearchIndex: DVD
    # salesrank
    res = Amazon::Ecs.item_search(title, :item_page => 1, :country => "jp", :sort => 'salesrank', :search_index => 'DVD')
    # 返ってきたXMLを表示（res.doc.to_sでも多分OK）

    res.items.each do |item|
      # TODO タイトル　値段　画像 商品種別(CD/DVD)
      puts item.get_elements("./ASIN")
      puts item.get("ItemAttributes/Title")
    end
  end


  # Kafkaから受信するタイトルリストは４つの想定
  # API 4 CALL
  title_list = ['ラブライブ', 'ニセコイ', '俺ガイル', 'アルスラーン戦記']
  title_list.each do |title|
    puts title
    AmazonConnecter.new.search(title)
  end


  # http://www.amazon.co.jp/dp/4839947591/?tag=XXXXXX-22

end