require 'amazon/ecs'
require 'json'

## Amazon API 1時間につき2,000リクエスト

class AmazonConnecter

  def initialize
    File.open './config/application.json' do |file|
      conf = JSON.load(file.read)
      @amazon_conf = conf["Amazon"]
    end

    Amazon::Ecs.options = {
        :associate_tag => @amazon_conf["associate_tag"],
        :AWS_access_key_id => @amazon_conf["AWS_access_key_id"],
        :AWS_secret_key => @amazon_conf["AWS_secret_key"]
    }
  end


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

    product_map_list = []

    res = Amazon::Ecs.item_search(title, :item_page => 1, :country => "jp", :sort => 'salesrank', :search_index => 'DVD', :response_group => 'Medium')
    # 返ってきたXMLを表示（res.doc.to_sでも多分OK）

    # レスポンス要素
    # https://images-na.ssl-images-amazon.com/images/G/09/associates/paapi/dg/index.html?CHAP_response_elements.html
    # http://www.ajaxtower.jp/ecs/responsegroup/index12.html
    res.items.each do |item|
      # TODO タイトル　値段　画像 商品種別(CD/DVD)
      # http://www.ajaxtower.jp/ecs/
      #puts item.get_elements("./ASIN")

      product_map = {}
      asin = item.get("ASIN")
      title = item.get("ItemAttributes/Title")
      price = item.get("ItemAttributes/ListPrice/FormattedPrice")
      release_date = item.get("ItemAttributes/ReleaseDate")
      image_url = item.get("LargeImage/URL")

      product_map['text'] = sprintf("%s 価格:%s 発売日:%s http://www.amazon.co.jp/dp/%s/?tag=%s", title, price, release_date, asin, @amazon_conf["associate_tag"])
      product_map['image_url'] = image_url
      product_map_list.push(product_map)
    end

    product_map_list
  end

  # http://www.amazon.co.jp/dp/4839947591/?tag=XXXXXX-22

end