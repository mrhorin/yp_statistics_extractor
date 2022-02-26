require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'json'

if ARGV.empty?
  raise <<-EOS
  引数で統計URLを指定してください。
  ruby main.rb [統計URL] [ファイル名]

  例: ruby main.rb 'http://temp.orz.hm/yp/getgmt.php?cn=TPちゃんねる' 'fuga.json'
  EOS
end

ARGV[1] ||= "details.json"

agent = Mechanize.new
agent.get ARGV[0]

res = []

agent.page.xpath("//table[@class='calendar']//td[@class='a']/a").each do |element|
   channel = {}
   link = element.attributes["href"].value
   page = agent.get link
   channel[:date] = page.at_xpath("//div[@class='main']//h4").text
   channel[:details] = []
   page.xpath("//table[@class='log']").children.each_with_index do |tr, idx|
    channel[:details] << tr.text if idx > 0
   end
   res << channel
   pp channel[:date]
   sleep 1
end

File.open(ARGV[1], mode = "w"){|f|
  f.write res.to_json
}

