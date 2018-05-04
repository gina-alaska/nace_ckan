resource_name :ckan_package

property :version, String, default: '2.6-trusty_amd64'
property :owner, String
property :group, String

action :install do
  remote_file "#{Chef::Config[:file_cache_path]}/python-ckan_#{new_resource.version}.deb" do
    source "http://packaging.ckan.org/python-ckan_#{new_resource.version}.deb"
    mode '0644'
    action :create_if_missing
  end

  dpkg_package 'python-ckan_2.6-trusty_amd64.deb' do
    source "#{Chef::Config[:file_cache_path]}/python-ckan_#{new_resource.version}.deb"
    action :install
    notifies :run, 'execute[fix_ckan_owners]', :immediately
    notifies :run, 'execute[fix_ckan_permissions]', :immediately
  end

  execute 'fix_ckan_owners' do
    command "chown -R #{new_resource.owner}:#{new_resource.group} /usr/lib/ckan"
    action :nothing
  end
  
  execute 'fix_ckan_permissions' do
    command "chmod -R g+w /usr/lib/ckan"
    action :nothing
  end
end
