# encoding: utf-8
require 'chefspec'
require 'spec_helper'
require 'fauxhai'

describe 'couchbase::moxi' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
    end.converge(described_recipe)
  end

  it 'enables a service moxi-server' do
    expect(chef_run).to enable_service('moxi-server')
    expect(chef_run).to_not enable_service('not_moxi-server')
  end

  it 'creates a template moxi-cluster.cfg.erb with attributes' do
    expect(chef_run).to create_template('/opt/moxi/etc/moxi-cluster.cfg').with(
      owner:   'moxi',
      group:  'moxi',
    )
    expect(chef_run).to_not create_template('/opt/moxi/etc/moxi-cluster.cfg').with(
      owner:   'not_moxi',
      group:  'not_moxi',
    )
  end
  it 'starts a service moxi-server' do
    expect(chef_run).to start_service('moxi-server')
    expect(chef_run).to_not start_service('not_moxi-server')
  end

  it 'downloads moxi-server-x86_64_1.8.1.rpm' do
    expect(chef_run).to create_remote_file_if_missing('/var/chef/cache/moxi-server_x86_64_1.8.1.rpm')
  end

  it 'installs rpm package moxi-server-x86_64_1.8.1.rpm' do
    expect(chef_run).to install_rpm_package('/var/chef/cache/moxi-server_x86_64_1.8.1.rpm')
  end

end
