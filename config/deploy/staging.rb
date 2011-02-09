set :application, "staging.sowhatsthedeal.com"
set :user, "kaliara"
set(:branch) do
  br = Capistrano::CLI.ui.ask "Branch: ".downcase
  if br == ""
    br = "staging"
  end
end

puts "--------------------------------------------------------------------------"
puts "----------------GOOD THING YOU MEANT TO DEPLOY TO STAGING!----------------"
puts "--------------------------------------------------------------------------"

role :web, "173.45.246.187"                          # Your HTTP server, Apache/etc
role :app, "173.45.246.187"                          # This may be the same as your `Web` server
role :db,  "173.45.246.187", :primary => true # This is where Rails migrations will run

after "deploy", "deploy:set_rails_env"
after "deploy", "deploy:set_rails_env"
