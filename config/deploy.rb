set :application, "bbs"
set :repository,  "git@github.com:sasasa/#{application}.git"
set :branch,      'master'
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#set :scm_username, 'saeki'
#set :scm_password, 'sasasa'

#set :use_sudo, false
set :deploy_to, "/mnt/app"
set :deploy_via, :copy
ssh_options[:keys] = %w(/home/sa/rails_test.id)
ssh_options[:user] = "root" 
role :web, "ec2-174-129-59-36.compute-1.amazonaws.com"                          # Your HTTP server, Apache/etc
role :app, "ec2-174-129-59-36.compute-1.amazonaws.com"                          # This may be the same as your `Web` server
role :db,  "ec2-174-129-59-36.compute-1.amazonaws.com", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
#  task :start, :roles=>:app do
#    run "sudo /etc/init.d httpd start"
#    run "ps -ef |grep httpd"
#  end
#  task :stop, :roles=>:app do
#    run "sudo /etc/init.d httpd stop"
#    run "ps -ef |grep httpd"
#  end
#  task :restart, :roles => :app  do
#    run "touch #{File.join(current_path,'tmp','restart.txt')}"
#    run "ps -ef |grep httpd"
#  end

#  desc "アップロードファイルにリンクをはる"
#  task :link_uploads do
#    run <<-CMD
#      if [ ! -d #{shared_path}/user_uploads ];then
#        mkdir -m 777 #{shared_path}/user_uploads;
#      fi;
#      cd #{release_path} && 
#      ln -nfs #{shared_path}/user_uploads #{release_path}/public/user_uploads
#    CMD
#  end
#  after "deploy:update_code", "deploy:link_uploads"

  desc "データベース設定ファイルにリンクをはる"
  task :link_database_yml do
    run <<-CMD
      if [ ! -d #{shared_path}/config ];then
        mkdir -m 777 #{shared_path}/config;
      fi;
      if [ ! -f #{shared_path}/config/local_environment.rb ];then
        echo #{shared_path}/config/local_environment.rb is empty!!!!!! Create local_environment.rb;
      fi;
      cd #{release_path} &&
      ln -nfs #{shared_path}/config/local_environment.rb #{release_path}/config/local_environment.rb
    CMD
  end
  after "deploy:update_code", "deploy:link_database_yml"

#  desc "ログをみる"
#  task :tail_log, :roles=>:app do
#    stream "tail -f #{shared_path}/log/production.log"
#  end

  task :restart, :roles => :app do
    run "#source /root/.bash_profile; 
      sudo /etc/init.d/mongrel_cluster restart; 
      sleep 5;
      isAlive=`ps -ef | grep 'ruby' | grep -v grep | wc -l`; 
      if [ $isAlive == 0 ]; then
        echo 'error mongrel restart'; 
        exit 1; 
      fi; 
      echo 'success mongrel restart!'; 
      exit 0;"
  end

  task :start, :roles => :app do
    run "#source /root/.bash_profile;
      sudo /etc/init.d/mongrel_cluster start; 
      sleep 5;
      isAlive=`ps -ef | grep 'ruby' | grep -v grep | wc -l`; 
      if [ $isAlive == 0 ]; then
        echo 'error mongrel start'; 
        exit 1; 
      fi; 
      echo 'success mongrel start!'; 
      exit 0;"
  end

  task :stop, :roles => :app do
    run "#source /root/.bash_profile;
      sudo /etc/init.d/mongrel_cluster stop; 
      sleep 5;
      isAlive=`ps -ef | grep 'ruby' | grep -v grep | wc -l`; 
      if [ $isAlive != 0 ]; then
        echo 'error mongrel stop'; 
        exit 1; 
      fi; 
      echo 'success mongrel stop!'; 
      exit 0;"
  end
end

