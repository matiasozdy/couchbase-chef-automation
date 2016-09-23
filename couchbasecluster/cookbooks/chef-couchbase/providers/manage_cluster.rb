#
# Cookbook Name:: couchbase
# Provider:: manage_cluster
#
# Copyright 2015, GannettDigital
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

use_inline_resources

def rebalance(path, ip, username, password)
  cmd = "#{path}/bin/couchbase-cli rebalance -c #{ip}:8091 -u #{username} -p #{password}"

  execute 'rebalancing cluster' do
    sensitive false
    command cmd
  end
end

action :init do
  return unless check_cluster(new_resource.username, new_resource.password) == false
  version = new_resource.version.split('.').first.to_i
  cmd = "#{new_resource.install_path}/bin/couchbase-cli cluster-init -c 127.0.0.1:8091 \
         -u #{new_resource.username} \
         -p #{new_resource.password} \
         --cluster-username=#{new_resource.username} \
         --cluster-password=#{new_resource.password} \
         --cluster-ramsize=#{new_resource.ramsize}"
  if version > 3
    cmd = "#{cmd} \
           --cluster-index-ramsize=#{new_resource.index_ramsize} \
           --services=#{new_resource.services}"
  end

  Chef::Log.warn("command is #{cmd}")
  execute 'cluster init to initialize server' do
    sensitive false
    command cmd
  end
end

action :join do
  return unless check_in_cluster(new_resource.username, new_resource.password, new_resource.master_ip) == false
  Chef::Log.warn("checking if #{new_resource.master_ip} == #{node['ipaddress']}")
  return unless node['ipaddress'] != new_resource.master_ip

  version = new_resource.version.split('.').first.to_i

  cmd = "#{new_resource.install_path}/bin/couchbase-cli server-add -c #{new_resource.master_ip}:8091 \
         -u #{new_resource.username} \
         -p #{new_resource.password} \
         --server-add=#{node['ipaddress']}:8091 \
         --server-add-username=#{new_resource.username} \
         --server-add-password=#{new_resource.password}"

  if version > 3
    cmd = "#{cmd} \
           --services=#{new_resource.services}"

  end

  Chef::Log.warn("joinging cluster wtih #{cmd}")
  execute 'joinging to cluster' do
    sensitive false
    command cmd
  end

  rebalance(new_resource.install_path, new_resource.master_ip, new_resource.username, new_resource.password)
end

action :leave do
  return unless check_cluster(new_resource.username, new_resource.password, node['ipaddress']) == true
  # Chef::Log.warn("checking if #{new_resource.master_ip} == #{node['ipaddress']}")
  # return unless node['ipaddress'] != new_resource.master_ip

  cmd = "#{new_resource.install_path}/bin/couchbase-cli rebalance -c #{new_resource.master_ip} \
         -u #{new_resource.username} \
         -p #{new_resource.password} \
         --server-remove=#{node['ipaddress']}:8091"

  execute 'leaving cluster' do
    sensitive false
    command cmd
  end
end
