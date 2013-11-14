include_recipe "nginx"
include_recipe "unicorn"

gem_package "bundler"

common = {:name => "kayak", :app_root => "/u/apps/kayak"}

directory common[:app_root] do
  recursive true
	owner "vagrant"
end

%w(config log tmp sockets pids assets bundle).each do |dir|
  directory "#{common[:app_root]}/shared/#{dir}" do
    recursive true
    mode 0755
    owner "vagrant"
  end
end

template "#{node[:unicorn][:config_path]}/#{common[:name]}.conf.rb" do
  mode 0644
  source "unicorn.conf.erb"
  variables common
end

nginx_config_path = "/etc/nginx/sites-available/#{common[:name]}.conf"

template nginx_config_path do
  mode 0644
  source "nginx.conf.erb"
  variables common.merge(:server_names => "kayak.test")
  notifies :reload, "service[nginx]"
end

nginx_site "kayak" do
  config_path nginx_config_path
  action :enable
end