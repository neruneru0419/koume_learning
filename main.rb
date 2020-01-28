#todo
#連鎖方法を考える
require "twitter"
require 'natto'
require "yahoo_keyphrase_api"

class KoumeTwitter
  def initialize
	@client = Twitter::REST::Client.new do |config|
	  config.consumer_key    = ENV['MY_CONSUMER_KEY']
	  config.consumer_secret = ENV['MY_CONSUMER_SECRET']
	  config.access_token    = ENV['MY_ACCESS_TOKEN']
	  config.access_token_secret = ENV['MY_ACCESS_TOKEN_SECRET']
	end
	YahooKeyphraseApi::Config.app_id = ENV['YAHOO_API_TOKEN']
	@yahoo_keyphrase_api = YahooKeyphraseApi::KeyPhrase.new
	@koume_tweet_id = @client.mentions_timeline.map{|tweet| tweet.id}
  end

  def get_tweet
	@timeline_tweet = []
	@timeline_tweet_id = []
	@client.home_timeline({count: 100}).each do |tweet|
	  unless tweet.text.include?("RT") or tweet.text.include?("@") or tweet.text.include?("http") or tweet.user.screen_name.include?("KoumeLearning") then
		@timeline_tweet.push(tweet.text)
		@timeline_tweet_id.push(tweet.id)
	  end
	end
	random_tweet_index = rand(@timeline_tweet)
	tweet = @timeline_tweet[random_tweet_index]
	tweet_id = @timeline_tweet_id[random_tweet_index]
	puts(tweet)
	phrases = @yahoo_keyphrase_api.extract(tweet)
	#点数が一番高いキーワードを代入
	max_point_phrase = phrases.max{|word, score| word[1] <=> score[1]}[0]
	p max_point_phrase
	@client.favorite(tweet_id)
	return max_point_phrase
  end

  def mention_timeline()
	@client.mentions_timeline.each do |tweet|
	  puts "\e[33m" + tweet.user.name + "\e[32m" + "[ID:" + tweet.user.screen_name + "]"
	  puts "\e[0m" + tweet.text
	  @koume_tweet_id.push(tweet.id)
	  unless @koume_tweet_id.include?(tweet.id) then
		reply = tweet.text.delete("@KoumeLearning")
		@client.favorite(tweet.id)
		@client.update("@#{tweet.user.screen_name} #{mention_timeline_tweet(reply)}",  options = {:in_reply_to_status_id => tweet.id})
		@koume_tweet_id.push(tweet.id)
	  end
	end
  end
end
	  
		
	  
class NattoParser
	def initialize()
	  @nm = Natto::MeCab.new
	end
	def parse(timeline_tweet)#<=string

	  @analyzed_tweets = [""]
	  @tweet_blocks = []
	  @nm.parse(timeline_tweet) do |n|
			@analyzed_tweets.push(n.surface)
	  end
	  (@analyzed_tweets.size - 2).times do |split_tweet|
			tweet_block = @analyzed_tweets[split_tweet..(split_tweet + 2)]
			@tweet_blocks.push(tweet_block)
	  end
	  return @tweet_blocks
	end
	def get_koume_speech()
	  File.open("koume.txt", "r") do |f|
	    (f.read).each_line do |speech|
		koume_speech += parse(speech)
	    end
	  end
	  return koume_speech
	end
	def markov_chain(koume_blocks, tweet)
	  #start_block = koume_blocks.select{|block| block[0] == ""}
	  #markov_chain_text = start_block.sample
	  particle = ["の", "も", "は", "に", "を", "で", "が"]
	  markov_chain_text = [" ", tweet, particle.sample]
	  chain_block = []
	  p markov_chain_text
	  while (markov_chain_text[-1] != "") do 
			koume_blocks.each do |tweet|
		    #語尾と語頭が同じブロックの候補を配列に格納
		  		chain_block.push(tweet[1..-1]) if markov_chain_text[-1] == tweet[0]
			end
			#候補がない場合強制的にループを終了
			break if chain_block.empty? then
			#ブロックの連結
			markov_chain_text += chain_block.sample
			#p markov_chain_text
			#配列の初期化
			chain_block = []
			cnt += 1
	  end
	  #ブロックを連結した文字列を返す
	  return markov_chain_text.join
	end
end

timeline_tweet = Thread.new do
  koume_twitter = KoumeTwitter.new
  natto_parser = NattoParser.new
  koume_speech = natto_parser.get_koume_speech
  loop do
    koume_speech = []
    tweet = koume_twitter.get_tweet
	@client.update(natto_parser.markov_chain(koume_speech, tweet))
    sleep(60)
  end
end

reply_tweet = Thread.new do
  koume_twitter = KoumeTwitter.new
  natto_parser = NattoParser.new
  koume_speech = natto_parser.get_koume_speech
  loop do
    @client.mentions_timeline.each do |tweet|
	  puts "\e[33m" + tweet.user.name + "\e[32m" + "[ID:" + tweet.user.screen_name + "]"
	  puts "\e[0m" + tweet.text
	  @koume_tweet_id.push(tweet.id)
	  unless @koume_tweet_id.include?(tweet.id) then
		reply = tweet.text.delete("@KoumeLearning")
		@client.favorite(tweet.id)
		@client.update("@#{tweet.user.screen_name} #{(natto_parser.markov_chain(koume_speech, reply)}",  options = {:in_reply_to_status_id => tweet.id})
		@koume_tweet_id.push(tweet.id)
	  end
	end
    sleep(60)
  end
end

if __FILE__ == $0
  timeline_tweet.join
  reply_tweet.join
end

