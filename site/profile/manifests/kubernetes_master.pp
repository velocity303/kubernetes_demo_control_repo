class profile::kubernetes_master {
  include ntp
  package { ['etcd','kubernetes']:
    ensure => present,
  }

  ini_setting { 'etcd_name setting':
    ensure  => present,
    path    => '/etc/etcd/etcd.conf',
    setting => 'ETCD_NAME',
    value   => 'default',
  }

  ini_setting { 'etcd_data_dir setting':
    ensure  => present,
    path    => '/etc/etcd/etcd.conf',
    setting => 'ETCD_DATA_DIR',
    value   => '"/var/lib/etcd/default.etcd"',
  }

  ini_setting { 'etcd_listen_client_urls setting':
    ensure  => present,
    path    => '/etc/etcd/etcd.conf',
    setting => 'ETCD_LISTEN_CLIENT_URLS',
    value   => '"http://0.0.0.0:2379"',
  }

  ini_setting { 'etcd_advertise_client_urls setting':
    ensure  => present,
    path    => '/etc/etcd/etcd.conf',
    setting => 'ETCD_ADVERTISE_CLIENT_URLS',
    value   => '"http://localhost:2379"',
  }

}
