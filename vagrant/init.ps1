servers = {
	:master => '192.168.137.10',
	:node1 => '192.168.137.11',
	:node2 => '192.168.137.12'
}
foreach($server in servers) {
  ssh-keygen -R $server
}