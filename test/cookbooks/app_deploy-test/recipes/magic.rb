deploy_key = data_bag_item('secrets', 'deploy_key')
info = app_deploy_info('https://github.com/jarosser06/magic',
                       deploy_key['key'])

Chef::Log.warn(deploy_key)
Chef::Log.warn(info)
