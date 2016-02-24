class profile::kubernetes_node (
  $kub_master_ip = '10.20.1.113',
  $ipaddr = $::networking[interfaces][enp0s8][ip],
) {
  include ntp
  package { 'flannel':
    ensure => present,
  }
  package { 'kubernetes':
    ensure => present,
  }

  # Configure Flannel
  ini_setting { 'etcd_ip setting':
    ensure  => present,
    path    => '/etc/sysconfig/flanneld',
    setting => 'FLANNEL_ETCD',
    value   => "\"http://${kub_master_ip}:2379\"",
    require => Package['flannel'],
    notify  => Service['flannel'],
  }

  # Configure Kubernetes
  ini_setting { 'kube_master_ip setting':
    ensure  => present,
    path    => '/etc/kubernetes/config',
    setting => 'KUBE_MASTER',
    value   => "\"--master=http://${kub_master_ip}:8080\"",
    require => Package['kubernetes'],
    notify  => Service['kube-proxy'],
  }
  
  # Define Kublet settings
  ini_setting { 'kubelet_address setting':
    ensure  => present,
    path    => '/etc/kubernetes/kubelet',
    setting => 'KUBELET_ADDRESS',
    value   => '"--address=0.0.0.0"',
    require => Package['kubernetes'],
    notify  => Service['kubelet'],
  }

  ini_setting { 'kubelet_port setting':
    ensure  => present,
    path    => '/etc/kubernetes/kubelet',
    setting => 'KUBELET_PORT',
    value   => '"--port=10250"',
    require => Package['kubernetes'],
    notify  => Service['kubelet'],
  }

  ini_setting { 'kubelet_port setting':
    ensure  => present,
    path    => '/etc/kubernetes/kubelet',
    setting => 'KUBELET_HOSTNAME',
    value   => "\"--hostname_override=${ipaddr}\"",
    require => Package['kubernetes'],
    notify  => Service['kubelet'],
  }

  ini_setting { 'kube_api_server setting':
    ensure  => present,
    path    => '/etc/kubernetes/kubelet',
    setting => 'KUBELET_API_SERVER',
    value   => "\"--api_servers=http://${kub_master_ip}:8080\"",
    require => Package['kubernetes'],
    notify  => Service['kubelet'],
  }

  ini_setting { 'kubelet_args setting':
    ensure  => present,
    path    => '/etc/kubernetes/kubelet',
    setting => 'KUBELET_ARGS',
    value   => '""',
    require => Package['kubernetes'],
    notify  => Service['kubelet'],
  }

  service { 'kube-proxy':
    ensure => running,
    enable => true,
  }

  service { 'kubelet':
    ensure => running,
    enable => true,
  }~>

  service { 'docker':
    ensure => running,
    enable => true,
  }

  service { 'flanneld':
    ensure => running,
    enable => true,
  }

}
