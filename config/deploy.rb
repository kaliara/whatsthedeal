require 'capistrano/ext/multistage'
set :default_stage, "staging"

set :application, "sowhatsthedeal.com"
set :user, "kaliara"
set :repository,  "git@github.com:kaliara/wtd.git"

set :deploy_to, "/home/kaliara/public_html/wtd"
set :deploy_via, :copy

set :port, 30000

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :deploy do
  task :set_rails_env do
    tmp = "#{current_path}/tmp/environment.rb"
    final = "#{current_path}/config/environment.rb"
    run <<-CMD
      echo "RAILS_ENV = 'staging'" > #{tmp};
      cat #{final} >> #{tmp} && mv #{tmp} #{final};
    CMD
  end
end

set :runner, user

after "deploy", "deploy:migrate" 
after "deploy", "deploy:cleanup"

namespace :deploy do  
  desc "Update the crontab file"  
  task :update_crontab, :roles => :db do  
    run "cd /home/kaliara/public_html/wtd/current && whenever --update-crontab wtd"  
  end  
end


namespace :assets do
  task :symlink, :roles => :app do
    run "ln -nfs #{shared_path}/system/assets/dc #{release_path}/public/dc"
    run "ln -nfs #{shared_path}/system/assets/images #{release_path}/public/images"
    run "ln -nfs #{shared_path}/system/assets/emails #{release_path}/public/emails"
  end
end