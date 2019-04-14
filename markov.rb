require 'natto'

def analysis (t)
  nm = Natto::MeCab.new
  i = [""]
  cnt = 1
  nm.parse(t) do |n|
    i[cnt] = n.surface
    cnt += 1
  end
  n = Array.new(i.size - 2).map{Array.new(3)}
  cnt = 0
  (i.size - 2).times do |hoge|
    3.times do |huga|
      n[hoge][huga] = i[cnt]
      cnt += 1
    end
    cnt -= 2
  end 
  return n
end

def chain(rensa, test)
kouho = []
flg = false
  test.each do |hoge|
    hoge.each do |huga|
      if rensa[-1] == huga[0] then
        kouho.push(huga)
      end
    end
  end
  
  ran = rand(kouho.size)

  p kouho[ran]
  if kouho[ran].nil? then
    puts "nilです"
    return rensa + ["…"], false
  elsif kouho.empty? and !(kouho.nil?) then
    puts "emptyです"
    return rensa, true
  else
    puts "elseです"
    return rensa + kouho[ran][1..(kouho[ran].size)], false
  end
end
