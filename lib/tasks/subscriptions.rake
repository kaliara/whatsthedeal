#!/usr/bin/ruby
require 'mechanize'
require 'logger'

namespace :subscriptions do

  desc "syncs internal subscription list with mailboto data"
  task :sync => :environment do
    
    lists = {
      "1621"  => "gets_daily_deal_email",
      "10211" => "gets_happy_hour_announcement_email"
    }

    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    jar = agent.cookie_jar
    jar.load("/home/kaliara/public_html/wtd/mailboto.txt", :cookiestxt)

    lists.each do |list_id, wtd_list|
      # Daily Deal
      page = agent.post("https://www.mailboto.com/cgi-bin/uls/uls_admin.cgi?filterexport=#{list_id}=", "action" => "filterexport", "listid" => "#{list_id}", "archs" => "", "cancelled" => "1", "delim" => "comma", "whichorder" => "1", "dowhat" => "1")
      emails = page.body.split(/\n/)

      User.find(:all, :conditions => ["#{wtd_list} = 1 and email in (#{emails.collect{|e| "'" + e + "'"}.join(",")})"]).each do |user|
        user[wtd_list] = false
        user.save
        puts "removed #{user.email} from the #{wtd_list} list"
      end
    end
  end
end