resource_name :ckan_plugin

property :plugin_name, String, required: true
property :source, String
property :install_path, String
property :tar_compress, String, default: 'z'
property :tar_flags, String
property :owner, String
property :group, String

action :install do
  plugin_path = new_resource.install_path || ::File.join('/usr/lib/ckan/default/src/', new_resource.name)
  plugin_archive = "#{Chef::Config[:file_cache_path]}/#{new_resource.name}.tar.bz2"

  directory plugin_path do
    recursive true
    owner new_resource.owner if new_resource.owner
    group new_resource.group if new_resource.group
  end

  tar_extract new_resource.source do
    target_dir plugin_path
    tar_flags [ '--strip-components 1' ]
    creates ::File.join(plugin_path, 'setup.py')
  end

  bash "install_#{new_resource.name}_ckan_extension" do
    code '/usr/lib/ckan/default/bin/python setup.py develop'
    cwd plugin_path
  end

  pip_requirements ::File.join(plugin_path, 'dev-requirements.txt') do
    python '/usr/lib/ckan/default/bin/python'
    action :install
    only_if { ::File.exists?(::File.join(plugin_path, 'dev-requirements.txt')) }
  end

  pip_requirements ::File.join(plugin_path, 'requirements.txt') do
    python '/usr/lib/ckan/default/bin/python'
    action :install
    only_if { ::File.exists?(::File.join(plugin_path, 'requirements.txt')) }
  end
end

action :active do
  node.default['ckan']['plugins'][new_resource.plugin_name] = true
end
