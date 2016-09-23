def check_cluster(username, password, ip = 'localhost')
  uri = URI("http://#{ip}:8091/pools/default")
  check = Net::HTTP::Get.new(uri)
  check.basic_auth username, password
  res = Net::HTTP.start(uri.hostname, uri.port, :open_timeout => 10) { |http| http.request(check) }
  if res.code == '200'
    return true
  else
    return false
  end
end

def check_bucket(username, password, bucket)
  uri = URI("http://localhost:8091/pools/default/buckets/#{bucket}")
  check = Net::HTTP::Get.new(uri)
  check.basic_auth username, password
  res = Net::HTTP.start(uri.hostname, uri.port, :open_timeout => 10) { |http| http.request(check) }
  Chef::Log.warn("res code is #{res.code}")
  if res.code == '200'
    return true
  else
    return false
  end
end

def get_node_info(username, password, ipaddress)
  uri = URI("http://#{ipaddress}:8091/pools/default")
  check = Net::HTTP::Get.new(uri)
  check.basic_auth username, password
  res = Net::HTTP.start(uri.hostname, uri.port, :open_timeout => 10) { |http| http.request(check) }
  return unless res.code == '200'
  JSON.parse(res.body)
end

def check_in_cluster(username, password, ipaddress)
  info = get_node_info(username, password, ipaddress)
  if info['nodes'].length > 1
    return true
  else
    return false
  end
end

def get_replica_json(username, password, ipaddress)
  uri = URI("http://#{ipaddress}:8091/pools/default/remoteClusters")
  check = Net::HTTP::Get.new(uri)
  check.basic_auth username, password
  res = Net::HTTP.start(uri.hostname, uri.port, :open_timeout => 10) { |http| http.request(check) }
  return unless res.code == '200'
  JSON.parse(res.body)
end

def check_replication(username, password, ipaddress, replica_name)
  info = get_replica_json(username, password, ipaddress)
  print info
  info.each do |replication|
    name = replication['uri'].split('/')
    return true if name[-1] == replica_name && replication['deleted'] == false
  end
  false
end

def check_bucket_replication(username, password, ipaddress, install_path, bucket)
  output = Mixlib::ShellOut.new("#{install_path}/bin/couchbase-cli xdcr-replicate -c #{ipaddress}:8091 -u #{username} -p #{password} --list | grep source")
  output.run_command
  output.each_line do |line|
    bucket_name = line.sub(/\s+/, '').sub(/\t/, '').sub(/\n/, '').split(':')
    return true if bucket_name[1].strip == bucket
  end
  false
end

def check_for_bucket_replication(username, password, ipaddress, install_path)
  output = Mixlib::ShellOut("#{install_path}/bin/couchbase-cli xdcr-replicate -c #{ipaddress}:8091 -u #{username} -p #{password} --list")
  output.run_command
  return true if output.length > 1
  false
end
