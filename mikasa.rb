require './lib/amazon_connecter'
require './lib/twitter_connecter'
require './lib/download_media'

include DownloadMedia

# if media
#@tw.update_with_media(tweet_data["tweet_msg"], File.new(tweet_data["media"]))

# Kafkaから受信するタイトルリストは４つの想定
# API 4 CALL
title_list = ['ラブライブ', 'ニセコイ', '俺ガイル', 'アルスラーン戦記']
title_list.each do |title|
  puts title
  AmazonConnecter.new.search(title)
end

