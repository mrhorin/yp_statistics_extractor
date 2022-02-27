require 'bundler/setup'
require 'mechanize'
require 'json'

# 統計URL
if ARGV.empty?
  raise <<-EOS
  引数で統計URLを指定してください。
  ruby main.rb [統計URL] [ファイル名]

  例: ruby main.rb 'http://temp.orz.hm/yp/getgmt.php?cn=TPちゃんねる' 'fuga.json'
  EOS
end

# ファイル名
ARGV[1] ||= "details.json"

def element? element
  element.class == Nokogiri::XML::Element
end

res = []
agent = Mechanize.new
agent.get ARGV[0]

# カレンダーから日付ごとの統計情報を取得
agent.page.xpath("//table[@class='calendar']//td[@class='a']/a").each do |element|
   channel = {}
   link = element.attributes["href"].value
   page = agent.get link
   channel[:date] = page.at_xpath("//div[@class='main']//h4").text
   channel[:details] = []
   # 統計情報から詳細一覧を取得
   page.xpath("//table[@class='log']").children.each_with_index do |tr, idx|
      if idx > 0
        row = {}
        row[:time] = element?(tr.children[0]) ? tr.children[0].text : nil
        row[:live_time] = element?(tr.children[1]) ? tr.children[1].text : nil
        if element? tr.children[2]
          counts = tr.children[2].text.gsub("\s","").split("/")
          row[:listener] =  counts[0] ? counts[0] : ""
          row[:relay] =  counts[1] ? counts[1] : ""
        end
        row[:desc] = element?(tr.children[3]) ? tr.children[3].text.strip : nil
        channel[:details] << row
      end
   end
   res << channel
   puts "#{channel[:date]}: (#{channel[:details][0][:listener]}/#{channel[:details][0][:relay]})#{channel[:details][0][:desc]}"
   sleep 1
end

File.open(ARGV[1], mode = "w"){|f| f.write res.to_json}
