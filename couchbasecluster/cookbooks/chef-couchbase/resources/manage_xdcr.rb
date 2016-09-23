#
# Cookbook Name:: couchbase
# Resource:: manage_xdcr
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

actions :create, :delete, :replicate, :delete_replicate

attribute :remote_cluster_name, :kind_of => String, :name_attribute => true
attribute :username, :kind_of => String
attribute :password, :kind_of => String
attribute :install_path, :kind_of => String, :default => '/opt/couchbase'
attribute :master_ip, :kind_of => String, :default => '127.0.0.1'
attribute :replica_ip, :kind_of => String
attribute :replica_username, :kind_of => String
attribute :replica_password, :kind_of => String
attribute :demand_encryption, :kind_of => [TrueClass, FalseClass], :default => false
attribute :certificate, :kind_of => String

attribute :from_bucket, :kind_of => String
attribute :to_bucket, :kind_of => String
attribute :checkpoint_interval, :kind_of => Integer, :default => 1800
attribute :worker_batch_size, :kind_of => Integer, :default => 500
attribute :doc_batch_size, :kind_of => Integer, :default => 2048
attribute :failure_restart_interval, :kind_of => Integer, :default => 30
attribute :optimistic_replication_threshold, :kind_of => Integer, :default => 256
attribute :source_nozzle_per_node, :kind_of => Integer, :default => 2
attribute :target_nozzle_per_node, :kind_of => Integer, :default => 2
attribute :log_level, :kind_of => String, :default => 'Info'
attribute :stats_interval, :kind_of => Integer, :default => '1000'
attribute :replication_mode, :kind_of => String, :default => 'xmem'
attribute :filter_expression_mode, :kind_of => String

def initialize(*args)
  super
  @action = :create
end
