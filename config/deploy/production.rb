set :application, "sowhatsthedeal.com"
set :user, "kaliara"

role :web, "173.45.244.235"                          # Your HTTP server, Apache/etc
role :app, "173.45.244.235"                          # This may be the same as your `Web` server
role :db,  "173.45.244.235", :primary => true # This is where Rails migrations will run

after "deploy:symlink", "deploy:update_crontab"  
after "deploy:symlink", "assets:symlink"