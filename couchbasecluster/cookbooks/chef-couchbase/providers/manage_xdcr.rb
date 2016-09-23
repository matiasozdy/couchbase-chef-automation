#
# Cookbook Name:: couchbase
# Provider:: manage_xdcr
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

def xdcr_setup_command(command, ipaddress, install_path, options)
  "#{install_path}/bin/couchbase-cli xdcr-setup --#{command} -c #{ipaddress}:8091 #{options}"
end

def xdcr_replicate_command(command, ipaddress, install_path, options)
  "#{install_path}/bin/couchbase-cli xdcr-replicate --#{command} -c #{ipaddress}:8091 #{options}"
end

def get_replicate_id(username, password, ipaddress, install_path, bucket)
  output = Mixlib::ShellOut("#{install_path}/bin/couchbase-cli xdcr-replicate --list -c #{ipaddress}:8091 \
         -u #{username} -p #{password} --list| grep #{bucket}|grep stream")
  output.run_command
  rep_id = output.sub(/\s+/, '').sub(/\t/, '').sub(/\n/, '').split(':')
  # id = rep_id[1].split('/')
  # Chef::Log.warn("id is #{id[0].strip}")
  rep_id[1].strip
end

action :create do
  return unless check_replication(new_resource.username, new_resource.password, new_resource.master_ip, new_resource.remote_cluster_name) == false

  options = "-u #{new_resource.username} \
             -p #{new_resource.password} \
             --xdcr-hostname=#{new_resource.replica_ip}:8091 \
             --xdcr-cluster-name=#{new_resource.remote_cluster_name} \
             --xdcr-username=#{new_resource.replica_username} \
             --xdcr-password=#{new_resource.replica_password}"
  if new_resource.demand_encryption == true
    options = "#{options} \
               --xdcr-demand-encryption=1 \
               --xdcr-certificate=#{new_resource.certificate}"
  end

  cmd = xdcr_setup_command('create', new_resource.master_ip, new_resource.install_path, options)

  execute 'creaet xdcr replication' do
    sensitive false
    command cmd
  end
end

action :delete do
  Chef::Log.warn('checking for replication')
  return unless check_replication(new_resource.username, new_resource.password, new_resource.master_ip, new_resource.remote_cluster_name) == true

  if check_for_bucket_replication(new_resource.username, new_resource.password, new_resource.master_ip, new_resource.install_path) == true
    Chef::Log.warn('found bucket cannot delete')
    return
  end

  Chef::Log.warn('found replication')
  options = "-u #{new_resource.username} \
             -p #{new_resource.password} \
             --xdcr-cluster-name=#{new_resource.remote_cluster_name}"

  cmd = xdcr_setup_command('delete', new_resource.master_ip, new_resource.install_path, options)

  execute 'delete xdcr replication' do
    sensitive false
    command cmd
  end
end

action :replicate do
  return if check_bucket_replication(new_resource.username,
                                     new_resource.password,
                                     new_resource.master_ip,
                                     new_resource.install_path,
                                     new_resource.from_bucket) == true

  options = "-u #{new_resource.username} \
             -p #{new_resource.password} \
             --xdcr-cluster-name=#{new_resource.remote_cluster_name} \
             --xdcr-from-bucket=#{new_resource.from_bucket} \
             --xdcr-to-bucket=#{new_resource.to_bucket}"

  cmd = xdcr_replicate_command('create', new_resource.master_ip, new_resource.install_path, options)

  execute 'replicate buckets' do
    sensitive false
    command cmd
  end
end

action :delete_replicate do
  return if check_bucket_replication(new_resource.username,
                                     new_resource.password,
                                     new_resource.master_ip,
                                     new_resource.install_path,
                                     new_resource.from_bucket) == false
  replicate_id = get_replicate_id(new_resource.username,
                                  new_resource.password,
                                  new_resource.master_ip,
                                  new_resource.install_path,
                                  new_resource.from_bucket)

  options = "-u #{new_resource.username} \
             -p #{new_resource.password} \
             --xdcr-cluster-name=#{new_resource.remote_cluster_name} \
             --xdcr-replicator=#{replicate_id}"

  cmd = xdcr_replicate_command('delete', new_resource.master_ip, new_resource.install_path, options)

  execute 'delete replicate buckets' do
    sensitive false
    command cmd
  end
end
