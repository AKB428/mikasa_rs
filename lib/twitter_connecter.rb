require 'json'
require 'twitter'

class TwitterConnecter

#ref https://github.com/sferik/twitter/blob/master/examples/Configuration.md
#ref http://qiita.com/innocent_zero/items/8c5f4c95881dd6b416f8

  def initialize
    File.open './config/application.json' do |file|
      conf = JSON.load(file.read)
      twitter_conf = conf["Twitter"]

      @tw = Twitter::REST::Client.new(
          :consumer_key => twitter_conf["consumer_key"],
          :consumer_secret => twitter_conf["consumer_secret"],
          :access_token => twitter_conf["access_token"],
          :access_token_secret => twitter_conf["access_token_secret"]
      )

    end
  end

  def tweet_list(msg_list)
    msg_list.each do |msg|
      @tw.update(msg)
      sleep 10
    end
  end

  def tweet_list_with_media(msg_map_list)

    msg_map_list.each do |msg_map|

      begin
        if msg_map['image_path']
          @tw.update_with_media(msg_map['text'], File.new(msg_map['image_path']))
        else
          @tw.update(msg_map['text'])
        end
      rescue => ex
        puts ex.to_s
        puts ex.backtrace.join("\n")
      end

      sleep 10
    end

  end

end