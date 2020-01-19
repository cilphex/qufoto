set :application, "qufoto"
set :domain, "66.84.18.100"
set :user, "qufotoc"
set :repository, "svn+ssh://#{user}@#{domain}/home/#{user}/svn/#{application}/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

set :use_sudo, false
set :deploy_to, "/home/#{user}/#{application}"
set :deploy_via, :checkout
set :chmod755, "app config db lib public vendor script script/* public/disp* public/cgi-bin public/cgi-bin/*"
set :keep_releases, 3

set :mongrel_port, "4000"
set :mongrel_nodes, "8"

default_run_options[:pty] = true

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "66.84.18.100"
role :web, "66.84.18.100"
role :db,  "66.84.18.100", :primary => true