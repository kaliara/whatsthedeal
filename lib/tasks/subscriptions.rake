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
      page = agent.post("https://www.mailboto.com/cgi-bin/uls/uls_admin.cgi?filterexport=#{list_id}=", "action" => "filterexport", "listid" => "#{list_id}", "archs" => "", "cancelled" => "1", "delim" => "comma", "whichorder" => "1", "dowhat" => "1")
      emails = page.body.split(/\n/)

      User.find(:all, :conditions => ["#{wtd_list} = 1 and email in (#{emails.collect{|e| "'" + e + "'"}.join(",")})"]).each do |user|
        user[wtd_list] = false
        user.save
        puts "removed #{user.email} from the #{wtd_list} list"
      end
    end
  end

  desc "updates mailboto with delayed subscriptions"
  task :update => :environment do
    DelayedSubscription.find(:all, :conditions => {:subscribed => false}).each do |delayed_subscription|
      @user = User.find_by_email(delayed_subscription.email)
      if !delayed_subscription.nil? and !@user.nil? and @user.customer? and @user.mailboto_api_request(delayed_subscription.referrer, delayed_subscription.list.to_s, false)
        puts "DS - added #{@user.email} to list #{delayed_subscription.list}"
        delayed_subscription.subscribed!
      # else
        # puts "DS - seems like there was an error while adding #{delayed_subscription.email} to list #{delayed_subscription.list}"
        # delayed_subscription.destroy
      end
    end
  end
end
