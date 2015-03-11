require 'yaml'
require 'chef/mash'
require 'net/http'
require 'chef/recipe'
require 'chef/resource/directory'
require 'chef/provider/directory'

module Application
  module DeployHelper

    def git_deployment_info(repo, deploy_key=nil, revision='master')
      install_git
      app = Application.new(run_context, repo, deploy_key, revision)
      app.info(node.chef_environment)
    end

    def install_git
      pkg = Chef::Resource::Package.new('git', run_context)
      pkg.run_action :install
    end

    class Application
      def initialize(run_context, repo, deploy_key=nil, revision='master')
        @run_context = run_context
        @repo = repo
        @deploy_key = deploy_key
        @revision = revision
        @cache_dir = ::File.join(Chef::Config[:file_cache_path],
                                 repo_name)
      end

      def info(environment)
        create_cache_dir
        puts @deploy_key

        unless @deploy_key.nil?
          create_ssh_wrapper
          create_deploy_key
        end
        checkout_git_repo

        deploy_yaml = ::File.join(@cache_dir, 'cache/.deploy.yml')
        return nil unless ::File.exist? deploy_yaml
        yaml = YAML.load(IO.read(deploy_yaml))

        compiled_info = Mash.new
        yaml.each do |k, v|
          if v.has_key? environment
            compiled_info[k] = v[environment]
          else
            compiled_info[k] = v['default']
          end
        end
        compiled_info
      end

      def checkout_git_repo
        repo = Chef::Resource::Git.new(repo_name, @run_context)
        repo.repository @repo
        repo.ssh_wrapper ssh_wrapper unless @deploy_key.nil?
        repo.reference @revision
        repo.destination ::File.join(@cache_dir, 'cache')
        repo.run_action :sync
      end

      def create_cache_dir
        dir = Chef::Resource::Directory.new(@cache_dir, @run_context)
        dir.mode 0755
        dir.owner 'root'
        dir.group 'root'
        dir.run_action :create
      end

      def repo_name
        return @repo_name unless @repo_name.nil?
        begin
          uri_path = URI.parse(@repo).path
          @repo_name = uri_path.byteslice(1, uri_path.length)
        rescue
          @repo_name = @repo.split(':').last
        end
        @repo_name.gsub!('/', '_')
        @repo_name
      end

      def ssh_wrapper
        return @ssh_wrapper unless @ssh_wrapper.nil?
        @ssh_wrapper = ::File.join(@cache_dir, '.ssh_wrapper')
        @ssh_wrapper
      end

      def create_ssh_wrapper
        script = Chef::Resource::Template.new(ssh_wrapper, @run_context)
        script.mode 0554
        script.owner 'root'
        script.group 'root'
        script.source 'git-ssh-wrapper.erb'
        script.cookbook 'deploy-helper'
        script.variables(cache_dir: @cache_dir)
        script.run_action :create
      end

      def create_deploy_key
        key = ::File.join(@cache_dir, 'id_deploy')
        deploy_key = Chef::Resource::File.new(key, @run_context)
        deploy_key.mode 0400
        deploy_key.sensitive true
        deploy_key.owner 'root'
        deploy_key.group 'root'
        deploy_key.content @deploy_key
        deploy_key.run_action :create
      end
    end
  end
end

Chef::Recipe.send(:include, ::Application::DeployHelper)
Chef::Resource.send(:include, ::Application::DeployHelper)
Chef::Provider.send(:include, ::Application::DeployHelper)
