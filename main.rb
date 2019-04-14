require "./markov"
require "./gettweet"

koume = []
flg = false
File.open("koume.txt", "r") do |f|
    (f.read).each_line do |serihu|
        koume.push(serihu)
    end
end

koume.size.times do |hoge|
  text = koume[hoge]
  koume[hoge] = analysis(text)
end
loop do
  result = get_tweet
  result.slice!(-1) if result[-1].empty?
  p result
  loop do 
  # puts result.join
    result, flg = chain(result, koume)
    break if result[-1].empty? or flg or 2 <= result.join.count("…") or 2 <= result.join.count("。") 
  end
  words = result.join
  words.gsub!(/○○○/, 'P')
  words.gsub!(/○○/, 'P')
  words.gsub!(/〇〇/, 'P')
  words.gsub!(/○/, 'P')
  puts words
  @client.update words
  sleep(900)
end