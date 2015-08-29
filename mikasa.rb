require './lib/amazon_connecter'
require './lib/twitter_connecter'
require './lib/download_media'
require 'poseidon'

include DownloadMedia

topic = ARGV[0]

@amazon_connecter = AmazonConnecter.new
@twitter_connecter = TwitterConnecter.new

File.open './config/application.json' do |file|
  @conf = JSON.load(file.read)
  @kafka_conf = @conf["Kafka"]
end

# title_listは４つまでのアニメ作品タイトルの配列
def search_and_tweet_trend_production(title_list)
  title_list.each do |title|
    begin
      product_map_list = @amazon_connecter.search(title, 140)
      #p product_map_list

      tweet_map_list = []
      product_map_list.each do |product_map|
        tweet = {
            "text" =>  product_map['text'],
            "image_path" => download_image(product_map['image_url'], @conf['product_image_path'])
        }
        tweet_map_list.push(tweet)
      end
      #p tweet_map_list

      @twitter_connecter.tweet_list_with_media(tweet_map_list)

    rescue => ex
      puts ex.to_s
    end
  end
end


def input_msg_to_array(input_msg)

  ds = input_msg.gsub(/,$/,'')
  ar = ds.split(',')
  title_list = []
  ar.each do |tittle_and_count|
    tc = tittle_and_count.split(':')
    title_list.push(tc[0])
  end
  title_list
end

consumer = Poseidon::PartitionConsumer.new(@kafka_conf['group_id'], @kafka_conf['hostname'], @kafka_conf['port'],
                                           topic, 0, :latest_offset)
loop do
  messages = consumer.fetch
  messages.each do |m|
    puts m.value
    title_list = input_msg_to_array(m.value.force_encoding('utf-8'))
    p title_list
    search_and_tweet_trend_production(title_list[0..3])
    # CRONで１時間に1度回すためexitする
    exit
  end
end

