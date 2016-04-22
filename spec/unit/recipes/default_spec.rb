#
# Cookbook Name:: nace-ckan
# Spec:: default
#
# The MIT License (MIT)
#
# Copyright (c) 2016 UAF GINA
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'spec_helper'

describe 'nace-ckan::default' do
  context 'When all attributes are default, on Ubuntu 14.04' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs libpq5' do
      expect(chef_run).to install_package('libpq5')
    end

    it 'install apache using httpd cookbook' do
      expect(chef_run).to create_httpd_service('default')
    end

    it 'install mod_wsgi using httpd cookbook' do
      expect(chef_run).to create_httpd_module('wsgi')
    end

    it 'installs nginx' do
      expect(chef_run).to install_package('nginx')
    end

    it 'stops and disables nginx' do
      expect(chef_run).to stop_service('nginx')
      expect(chef_run).to disable_service('nginx')
    end

    it 'fetches the ckan .deb' do
      expect(chef_run).to create_remote_file_if_missing('/var/chef/cache/python-ckan_2.5-trusty_amd64.deb').with(
        source: 'http://packaging.ckan.org/python-ckan_2.5-trusty_amd64.deb'
      )
    end

    it 'installs ckan' do
      expect(chef_run).to install_dpkg_package('python-ckan_2.5-trusty_amd64.deb').with(
        source: '/var/chef/cache/python-ckan_2.5-trusty_amd64.deb'
      )
    end
  end
end
