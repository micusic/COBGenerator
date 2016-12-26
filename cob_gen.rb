require 'selenium-webdriver'

class CobGenerator

  def load_old_data(data_file)
    data_old = []
    if File.exist? data_file
      f = File.open data_file
      f.each_line do |line|
        data_old << eval(line)
      end
    end
    data_old
  end

end

cob_generator = CobGenerator.new
data_file = File.dirname(__FILE__)+"/story_data"
data_old = cob_generator.load_old_data(data_file)

driver = Selenium::WebDriver.for :chrome
driver.navigate.to 'https://jira'

puts "Please navigate to the page has cards."
gets
puts "moving on..."

forpick=[]
elements = driver.find_elements(:xpath, "//ul[@class='ghx-columns']/li[@data-column-id='750']//div[@class='ghx-issue-fields']")
elements.each do |element|
  no = element.find_element(:xpath, "div[@class='ghx-key']/a").attribute("title")
  content = element.find_element(:xpath, "div[@class='ghx-summary']").attribute("title")
  forpick << {:no => no, :content => content}
end

qa=[]
elements = driver.find_elements(:xpath, "//ul[@class='ghx-columns']/li[@data-column-id='752']//div[@class='ghx-issue-fields']")
elements.each do |element|
  no = element.find_element(:xpath, "div[@class='ghx-key']/a").attribute("title")
  content = element.find_element(:xpath, "div[@class='ghx-summary']").attribute("title")
  qa << {:no => no, :content => content}
end

ca=[]
elements = driver.find_elements(:xpath, "//ul[@class='ghx-columns']/li[@data-column-id='753']//div[@class='ghx-issue-fields']")
elements.each do |element|
  no = element.find_element(:xpath, "div[@class='ghx-key']/a").attribute("title")
  content = element.find_element(:xpath, "div[@class='ghx-summary']").attribute("title")
  ca << {:no => no, :content => content}
end

done=[]
elements = driver.find_elements(:xpath, "//ul[@class='ghx-columns']/li[@data-column-id='754']//div[@class='ghx-issue-fields']")
elements.each do |element|
  no = element.find_element(:xpath, "div[@class='ghx-key']/a").attribute("title")
  content = element.find_element(:xpath, "div[@class='ghx-summary']").attribute("title")
  done << {:no => no, :content => content}
end

indev=[]
elements = driver.find_elements(:xpath, "//ul[@class='ghx-columns']/li[@data-column-id='751']//div[@class='ghx-issue-fields']")
elements.each do |element|
  no = element.find_element(:xpath, "div[@class='ghx-key']/a").attribute("title")
  content = element.find_element(:xpath, "div[@class='ghx-summary']").attribute("title")
  story = {:no => no, :content => content}
  element.find_element(:xpath, "div[@class='ghx-key']/a").click
  begin
    wait = Selenium::WebDriver::Wait.new(:timeout => 3)
    wait.until { driver.find_element(:id => "foo") }
  rescue
  end
  comments = driver.find_elements(:xpath, "//div[@id='ghx-tab-comments']/div[@class='ghx-container']//div[@class='action-body']")
  story[:comment]=comments[0].attribute("innerHTML").gsub(/<[^>]*>/,"") unless comments.empty?
  indev << story
end

result = "#{forpick}" + "\n#{indev}" + "\n#{qa}" + "\n#{ca}" + "\n#{done}"
puts result

f = File.open(data_file, "w")
f.puts result
f.close

cob_file = File.dirname(__FILE__)+"/cob"
f = File.open(cob_file, "w")
name="Nicola"
date=Time.now.strftime("%b %d, %Y")
pu_no=forpick.size
qa_no=qa.size
ca_no=ca.size
done_no=done.size
pu_no_old=data_old[0].size
qa_no_old=data_old[2].size
ca_no_old=data_old[3].size
done_no_old=data_old[4].size
f.puts "Hi #{name},"
f.puts ""
f.puts "following are updates on #{date}:"
f.puts ""
indev.each do |story|
  f.puts "- #{story[:no]}, #{story[:content]}, is ONGOING."
  f.puts ""
  unless story[:comment].nil?
    f.puts "	Latest comment: #{story[:comment]}"
    f.puts ""
  end
end
f.puts "* There are #{pu_no} cards in the 'Ready To Pick Up' column, which has #{pu_no_old} yesterday."
f.puts ""
f.puts "* There are #{qa_no} cards in the 'QA' column, which has #{qa_no_old} yesterday."
f.puts ""
f.puts "* There are #{ca_no} cards in the 'Custom Acceptance' column, which has #{ca_no_old} yesterday."
f.puts ""
f.puts "* There are #{done_no} cards in the 'Ready to publish' column, which has #{done_no_old} yesterday."
f.close

driver.quit