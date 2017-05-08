class base {
  hiera_include('classes')

  ::docker::image { 'swarm': }

  ::docker::run { 'swarm':
    image   => 'swarm',
    command => "join --addr=${::ipaddress_eth1}:2375 consul://${::ipaddress_eth1}:8500/swarm_nodes"
  }
}

node 'manager1' {
  include base

  ::docker::run { 'swarm-manager':
    image   => 'swarm',
    ports   => '3000:2375',
    command => "manage consul://${::ipaddress_eth1}:8500/swarm_nodes",
    require => Docker::Run['swarm'],
  }
}

node 'worker1' {
  include base

	exec { "consul-join":
		path      => '/usr/local/bin/',
		command		=> 'consul join 10.20.3.10',
		require   => Class['consul'],
		before    => Class['docker'],
		tries     => 10,
		try_sleep => 1,
	}

	exec { 'zookeeper':
		path => '/usr/bin/',
		command => 'docker -H tcp://10.20.3.10:3000 run --name zookeeper -d -p 2181:2181 -p 2888:2888 -p 3888:3888 jplock/zookeeper',
		require => Class['docker'],
		tries     => 10,
    try_sleep => 1
	}

	exec { "solr1":
		path => '/usr/bin/',
		command => "docker -H tcp://10.20.3.10:3000 run --name solr1 --link zookeeper:ZK -d -p 8983:8983 solr bash -c '/opt/solr/bin/solr start -f -z $ZK_PORT_2181_TCP_ADDR:$ZK_PORT_2181_TCP_PORT'",
		require => Exec['zookeeper']
	}

	exec { "redis-master":
		path => '/usr/bin/',
		command => "docker -H tcp://10.20.3.10:3000 run --name redis-master -d -p 6379:6379 redis",
		require => Class['docker'],
		tries     => 10,
		try_sleep => 1
	}
}

node default {
  include base

  exec { "consul-join":
    path      => '/usr/local/bin/',
		command		=> 'consul join 10.20.3.10',
    require   => Class['consul'],
    before    => Class['docker'],
    tries     => 10,
    try_sleep => 1,
  }

	exec { "solr2":
		path => '/usr/bin/',
		command => "docker -H tcp://10.20.3.10:3000 run --name solr2 --link zookeeper:ZK -d -p 8984:8983 solr bash -c '/opt/solr/bin/solr start -f -z $ZK_PORT_2181_TCP_ADDR:$ZK_PORT_2181_TCP_PORT'",
		require => Class['docker']
	}

	exec { "redis-slave1":
		path => '/usr/bin/',
		command => "docker -H tcp://10.20.3.10:3000 run --name redis-slave1 --link redis-master:redis-master -d redis redis-server --slaveof redis-master 6379",
		require => Class['docker']
	}
}
