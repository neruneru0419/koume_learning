require "twitter"
require 'natto'
require "yahoo_keyphrase_api"
require "./api"

@client = Twitter::REST::Client.new do |config|
  config.consumer_key    = ENV['MY_CONSUMER_KEY']
  config.consumer_secret = ENV['MY_CONSUMER_SECRET']
  config.access_token    = ENV['MY_ACCESS_TOKEN']
  config.access_token_secret = ENV['MY_ACCESS_TOKEN_SECRET']
end

def tweet_cut(str)
    nm = Natto::MeCab.new
    i = [""]
    cnt = 0
    nm.parse(str) do |n|
        i[cnt] = n.surface
        cnt += 1
    end
    return i.slice(0..3)
end

def ext(target_word)
  YahooKeyphraseApi::Config.app_id = ENV['YAHOO_API_TOKEN']
  ykp = YahooKeyphraseApi::KeyPhrase.new
  begin
    phrases = ykp.extract(target_word)
  rescue
   puts "nil"
  end
  unless phrases.nil? then
    tweet = []
    scores = phrases.values
    word = phrases.keys
    i = 0
    scores.each do |score|
      if score >= 70 then
        tweet.push(word[i])
      end
      i += 1
    end

    ran = rand(tweet.size)

    return tweet[ran]
  end
end
def get_tweet
  tweet_kouho = []
  @client.home_timeline({count: 100}).each do |tweet|
      if not tweet.text.include?("RT") and not tweet.text.include?("@") and not tweet.text.include?("http") then
        puts tweet.text
        tweet_kouho.push(tweet.text)
        tweet_kouho.uniq! 
      end
  end
  #p tweet_kouho
  puts tweet_kouho.size
  i = tweet_kouho.size
  ran = rand(i)
  koume_start = []
  i.times do |hoge|
      koume_start[hoge] = tweet_cut(tweet_kouho[hoge])
      puts koume_start[hoge].join
  end
  return koume_start[ran]
end