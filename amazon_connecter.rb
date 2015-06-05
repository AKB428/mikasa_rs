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
  def search(title)
    res = Amazon::Ecs.item_search(title, :item_page => 1, :country => "jp")
    # 返ってきたXMLを表示（res.doc.to_sでも多分OK）

    res.items.each do |item|
      # TODO タイトル　値段　画像 商品種別(CD/DVD)
      puts item.get_elements("./ASIN")
      puts item.get("ItemAttributes/Title")
    end
  end

  title_list = ['ラブライブ', 'ニセコイ']
  title_list.each do |title|
    puts title
    AmazonConnecter.new.search(title)
  end

  // http://www.amazon.co.jp/dp/4839947591/?tag=XXXXXX-22

end