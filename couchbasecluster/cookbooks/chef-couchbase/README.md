DESCRIPTION
===========

Installs and configures Couchbase. Also has optional LWRP for setting up a cluster, buckets, and xcdr. Tested with couchbase version 4.

REQUIREMENTS
============

Chef 0.12 and Ohai 0.6.12 are required due to the use of platform_family.

Platforms
---------

* Debian family (Debian, Ubuntu etc)
* Red Hat family (Redhat, CentOS, Oracle etc)
* Microsoft Windows

Note that Couchbase Server does not support Windows 8 or Server 2012: see http://www.couchbase.com/issues/browse/MB-6395. This is targeted to be fixed in Couchbase 2.0.2.

ATTRIBUTES
==========

couchbase-server
----------------

* `node['couchbase']['server']['edition']`          - The edition of couchbase-server to install, "community" or "enterprise"
* `node['couchbase']['server']['version']`          - The version of couchbase-server to install
* `node['couchbase']['server']['database_path']`    - The directory Couchbase should persist data to
* `node['couchbase']['server']['index_path']`       - The directory Couchbase should persist index to
* `node['couchbase']['server']['log_dir']`          - The directory Couchbase should log to
* `node['couchbase']['server']['memory_quota_mb']`  - The per server RAM quota for data in megabytes
* `node['couchbase']['server']['index_memory_quota_mb']` - The per server RAM quota for the index in megabytes
* `node['couchbase']['server']['services']`         - Couchbase 4.0 and up. Services the node should run - data, query, and index 
                                                      Enterprise can do individual services, all community nodes must include data
* `node['couchbase']['server']['username']`         - The cluster's username for the REST API and Admin UI
* `node['couchbase']['server']['password']`         - The cluster's password for the REST API and Admin UI
* `node['couchbase']['server']['run_cluster_init']` - Boolean whether to initialize the node as a stand alone server.
                                                      Default is true. Setting go false will require node to be joined to a cluster
                                                      before it is usable.

moxi
----

* `node['couchbase']['moxi']['version']`            - The version of moxi to install
* `node['couchbase']['moxi']['package_file']`       - The package file to download
* `node['couchbase']['moxi']['package_base_url']`   - The base URL where the packages are located 
* `node['couchbase']['moxi']['package_full_url']`   - The full URL to the moxi package
* `node['couchbase']['moxi']['cluster_server']`     - The bootstrap server for moxi to contact for the node list
* `node['couchbase']['moxi']['cluster_rest_url']`   - The bootstrap server's full REST URL for retrieving the initial node list

RECIPES
=======

client
------

Installs the libcouchbase2 and devel packages for the c library.

server
------

Installs the couchbase-server package and starts the couchbase-server service. If run_cluster_init is true (default) will initialize the server.

moxi
----

Installs the moxi-server package and starts the moxi-server service.

Fixture Test Cookbook Recipes
-----------------------------

Examples recipes for cluster management, bucket management, and xdcr can be found under test/fixtures/cookbooks/test.

test_join_cluster
-----------------

Example recipe to join nodes into a cluster.

test_leave_cluster
------------------

Example recipe to remove a node from a cluster.

test_bucket_create
------------------

Example recipe to add a bucket to the cluster.

test_xdcr_create
----------------

Example recipe to establish xdcr between two cluster and replicate a bucket.

test_xdcr_delete
----------------

Example recipe to delete bucket replication and xdcr between two clusters.

RESOURCES/PROVIDERS
===================

couchbase_install_server
------------------------

### Actions

* `:install` - **Default** Installs couchbase-server from couchbase package repository.

### Attribute Parameters

* `version` - Version of couchbase to install (i.e.: 4.0.0).
* `edition` - Either community (default) or enterprise.

### Examples

```ruby
couchbase_install_server "self" do
  version '4.0.0'
  edition 'community'
end
```

couchbase_node_diretories
-------------------------

### Actions

* `:add` - **Default** Sets the data and index directories on the node

### Attribute Parameters

* `database_path` - The path to where database should persist
* `index_path` - The path to where the index should persist. If not set will default to database_path.
* `username` - The username to use to authenticate with Couchbase
* `password` - The password to use to authenticate with Couchbase
* `install_path` - Path to where couchbase is installed - /opt/couchbase.

### Examples

```ruby
couchbase_node_directories "self" do
  database_path '/opt/couchbase/var/lib/couchbase/data'
  index_path '/opt/couchbase/var/lib/couchbase/index'
  username 'Administrator'
  password 'password'
  install_path '/opt/couchbase'
end
```

couchbase_manage_cluster
------------------------

### Actions

* `:init` - **Default** Initialize node setting username and password for web ui.
* `:join` - Join a node to a cluster.
* `:leave` - Remove a node from a cluster.

### Attribute Parameters

* `services` - Version 4 and above. Defines the services the node will perform. One of data, index, query. For community edition every node must have data. This is primarily used when joining a node to a cluster but is required when running init.
* `ramsize` - Amount of RAM in MB to allocate to data
* `index_ramsize` - Amount of RAM in MB to allocate to index. If not set index is lumped in with data. 
* `version` - Version of couchbase. Needed to determine required attributes for 4 and above not supported on 3. Default is 4.0.0.
* `username` - The username to use to authenticate with Couchbase
* `password` - The password to use to authenticate with Couchbase
* `install_path` - Path to where couchbase is installed - /opt/couchbase.

* `master_ip` - Required and used only for :join and :leave. The ip address of the master node in the cluster.


### Examples

```ruby
couchbase_manager_cluster "default" do
  services 'data,index,query'
  version '4.0.0'
  ramsize '2048'
  index_ramsize '256'
  username 'Administrator'
  password 'password'
  install_path '/opt/couchbase'
end

couchbase_manager_cluster "default" do
  services 'data,index'
  version '4.0.0'
  username 'Administrator'
  password 'password'
  install_path '/opt/couchbase'
  master_ip '10.20.1.101'
  action :join
end

couchbase_manager_cluster "default" do
  services 'data,index'
  version '4.0.0'
  username 'Administrator'
  password 'password'
  install_path '/opt/couchbase'
  master_ip '10.20.1.101'
  action :leave
end
```

couchbase_manage_bucket
----------------

### Actions

* `:create` - **Default** Create a Couchbase bucket. If you run :create on an exist bucket it switches to edit.
* `:edit` - Edit settings for a couchbase bucket. If you run :edit on a bucket that does not exist it switches to :create.
* `:delete` - Delete a couchbase bucket.

### Attribute Parameters

* `bucket_name` - The name to use for the Couchbase bucket, defaults to the resource name
* `bucket_type` - Either couchbase or memcached.
* `bucket_ramsize` - The bucket's per server RAM quota for the entire cluster in megabytes
* `bucket_replicas` - Number of replicas, default is 1.
* `bucket_priority` - Bucket priority compared to other buckets either high or low, default is high.
* `bucket_password` - Password for bucket - optional, default is nil.
* `bucket_port` - Default is 11211 for SASL authentication or dedicated port with no password.
* `bucket_flush` - Enable or disable flush - default is false
* `bucket_index_replica` - Enable or disable defined number of replicas default is false.
* `bucketn_enable_priority` - Enables or disables index - default low.
* `username` - The username to use to authenticate with Couchbase
* `password` - The password to use to authenticate with Couchbase
* `install_path - The path to where couchbase is install - default is /opt/couchbase

### Examples

```ruby
couchbase_manage_bucket "test" do
  bucket_ramsize 128
  username 'Administrator'
  password 'password'
end

couchbase_manage_bucket "test" do
  bucket_ramsize 128
  username 'Administrator'
  password 'password'
  action :delete
end
```

couchbase_manage_xdcr
---------------------

### Actions
* `:create` - **Default** Create xdcr replication.
* `:delete` - Delete xdcr replication - you need to delete buckets replications first.
* `:replicate` - Create bucket replication.
* `:delete_replicate` - Delete bucket replication.

### Attribute Parameters
* `:remote_cluster_name` - Name to give replication, defaults to resource name.
* `:master_ip` - Ip address or host name of node in cluster to replicate from - master cluster.
* `:replica_ip` - Ip address or host name of node in cluster to replicate to - replica or slave cluster.
* `:replica_username` - Username of replica cluster.
* `:replica_password` - Password for replica cluster.
* `:demand_encryption` - Use encryption, default to false.
* `:certificate` - Path to certificate if demand_encryption is true.
* `username` - The username to use to authenticate with Couchbase
* `password` - The password to use to authenticate with Couchbase
* `install_path - The path to where couchbase is install - default is /opt/couchbase

* `:from_bucket` - Name of of bucket to replicate from on master cluster.
* `:to_bucket` - Name of bucket to replicate to on replica cluster - must exist.
* `:checkpoint_interval` - Interval between checkpoint in seconds between 60 and 14400, default is 1800.
* `:worker_batch_size` - Worker batch size in KB between 500 and 10000, default is 500.
* `:doc_batch_size` - Document batch size in KB between 10 and 100000 KB, default is 2048.
* `:failure_restart_interval` - Interval for restarting faild XDCR 1 to 300 seconds default is 30.
* `:optomistic_replication_threshold` - Document body size threshold (bytes) to trigger optimistic replication, default is 256.
* `:source_nozzle_per_node` - Number of source nozzles per node 1 - 100 default is 2. Should match target_nozzle_per_node.
* `:target_nozzle_per_node` - Number of outgoing nozzles per node 1 - 100, default is 2. Should match source_nozzles_per_node.
* `:log_level` - Logging level one of Error, Info, Debug, or Trace, default is Info.
* `:stats_interval` - Interval in MS for status updates, default is 1000.
* `:replication_mode` - Replication protocol either version 2 - xmem or version 1 - capi, default is xmem.
* `:filter_expression_mode` - Option filter expression.

### Examples

```ruby
couchbase_manage_xdcr 'test' do
  username 'Administrator'
  password 'password'
  replica_ip '10.30.1.101'
  master_ip '10.20.1.101'
  replica_username 'Administrator'
  replica_password 'Password'
end

couchbase_manage_xdcr 'test' do
  username 'Administrator'
  password 'password'
  master_ip '10.20.1.101'
  from_bucket 'beer-sample'
  to_bucket 'beer-sample'
  action :replicate
end

couchbase_manage_xdcr 'test' do
  username 'Administrator'
  password 'password'
  master_ip '10.20.1.101'
  from_bucket 'beer-sample'
  action :delete_replicate
end

couchbase_manage_xdcr 'test' do
  username 'Administrator'
  password 'password'
  master_ip '10.20.1.101'
  action :delete
end
```

LICENSE AND AUTHOR
==================

Author:: Dann S Washko (<dwashko@gannett.com>)
Author:: Chris Griego (<cgriego@getaroom.com>)
Author:: Morgan Nelson (<mnelson@getaroom.com>)
Author:: Julian Dunn (<jdunn@aquezada.com>)

Copyright 2015, Gannett

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
