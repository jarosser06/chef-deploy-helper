app_repo = 'git@github.com:jarosser06/magic'
deploy_key = data_bag_item('secrets', 'deploy_key')
info = git_deployment_info(app_repo, deploy_key['key'])

file '/root/id_deploy' do
  action :create
  mode 0400
  content deploy_key['key']
end

template '/root/ssh_wrapper' do
  action :create
  mode 0554
  source 'git-ssh-wrapper.erb'
  cookbook 'deploy-helper'
  variables(cache_dir: '/root')
end

Chef::Log.warn(info)

deploy_revision 'myapp' do
  repo app_repo
  revision info['revision'] || 'master'
  ssh_wrapper '/root/ssh_wrapper'
  symlink_before_migrate.clear
  symlinks.clear
  migrate info['migrate'] || false
  migration_command info['migration_command']
end
