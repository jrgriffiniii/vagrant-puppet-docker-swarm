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

node default {
  include base

  exec { "consul join 10.20.3.10":
    path      => '/usr/local/bin/',
    require   => Class['consul'],
    before    => Class['docker'],
    tries     => 10,
    try_sleep => 1,
  }

}
