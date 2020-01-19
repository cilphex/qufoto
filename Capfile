load 'deploy' if respond_to?(:namespace) # cap2 differentiator
# Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'

# ========================
# For Mongrel Cluster Apps
# ========================

namespace :deploy do

	# Note to self: you added the mongrel_upload_progress.conf shit, but it isn't used yet.

  task :start, :roles => :app do
    run "cd #{current_path} && mongrel_rails cluster::configure -e production -p #{mongrel_port}0 -N #{mongrel_nodes} -c #{current_path} --user #{user} --group #{user}"
    run "cd #{current_path} && mongrel_rails cluster::start"
    run "rm -rf /home/#{user}/public_html;ln -s #{current_path}/public /home/#{user}/public_html"
    run "mkdir -p #{deploy_to}/shared/config"
    run "mv #{current_path}/config/mongrel_cluster.yml #{deploy_to}/shared/config/mongrel_cluster.yml"
    run "ln -s #{deploy_to}/shared/config/mongrel_cluster.yml #{current_path}/config/mongrel_cluster.yml"
    
    # Following two lines added by Craig, 5/11/08
    run "mv #{current_path}/config/mongrel_upload_progress.conf #{deploy_to}/shared/config/mongrel_upload_progress.conf"
    run "ln -s #{deploy_to}/shared/config/mongrel_upload_progress.conf #{current_path}/config/mongrel_upload_progress.conf"
    
    # Added 7/16/09 (doesn't work?)
    run "ln -s #{deploy_to}/shared/cache #{current_path}/tmp/cache"
  end

  task :restart, :roles => :app do
    run "ln -s #{deploy_to}/shared/config/mongrel_cluster.yml #{current_path}/config/mongrel_cluster.yml"
    run "ln -s #{deploy_to}/shared/config/mongrel_upload_progress.conf #{current_path}/config/mongrel_upload_progress.conf" # Added by Craig 5/11/08
    run "cd #{current_path} && mongrel_rails cluster::restart"
    run "cd #{current_path} && chmod 755 #{chmod755}"
    
    # Added 7/16/09 (doesn't work?)
    run "ln -s #{deploy_to}/shared/cache #{current_path}/tmp/cache"
  end

end