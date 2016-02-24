class profile::kubernetes_master {
  include ntp
  package { ['etcd','kubernetes']:
    ensure => present,
  }
}
