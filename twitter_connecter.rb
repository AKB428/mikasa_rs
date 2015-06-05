require 'json'
require 'twitter'

class TwitterConnecter

#ref https://github.com/sferik/twitter/blob/master/examples/Configuration.md
#ref http://qiita.com/innocent_zero/items/8c5f4c95881dd6b416f8

  @tweet_sleep_time = 10

  File.open './config/application.json' do |file|
    conf = JSON.load(file.read)
    twitter_conf = conf["Twitter"]

    @tw = Twitter::REST::Client.new(
        :consumer_key => twitter_conf["consumer_key"],
        :consumer_secret => twitter_conf["consumer_secret"],
        :access_token => twitter_conf["access_token"],
        :access_token_secret => twitter_conf["access_token_secret"]
    )

    def tweet_list(msg_list)
      msg_list.each do |msg|
        tw.update(msg)
        sleep @tweet_sleep_time
      end
    end


  end
end