class profile::kubernetes_master {
  include ntp
  package { 'kubernetes':
    ensure => present,
  }

  # Configure /etc/etcd/etcd.conf for use as kubernetes master
  class { 'etcd':
    ensure                => 'latest',
    listen_client_urls    => 'http://0.0.0.0:2379',
    etcd_name             => 'default',
    advertise_client_urls => 'http://localhost:2379',
  }

  etcd_key { '/atomic.io/network/config':
    value => '{"Network":"172.17.0.0/16"}'
  }
  # Configure Kubernetes API server inside /etc/kubernetes/apiserver
  ini_setting { 'kube_api_address setting':
    ensure  => present,
    path    => '/etc/kubernetes/apiserver',
    setting => 'KUBE_API_ADDRESS',
    value   => '"--address=0.0.0.0"',
    notify  => Service['kube-apiserver'],
  }

  ini_setting { 'kube_api_port setting':
    ensure  => present,
    path    => '/etc/kubernetes/apiserver',
    setting => 'KUBE_API_PORT',
    value   => '"--port=8080"',
    notify  => Service['kube-apiserver'],
  }

  ini_setting { 'kubelet_port setting':
    ensure  => present,
    path    => '/etc/kubernetes/apiserver',
    setting => 'KUBELET_PORT',
    value   => '"--kubelet_port=10250"',
    notify  => Service['kube-apiserver'],
  }

  ini_setting { 'kube_etcd_servers setting':
    ensure  => present,
    path    => '/etc/kubernetes/apiserver',
    setting => 'KUBE_ETCD_SERVERS',
    value   => '"--etcd_servers=http://127.0.0.1:2379"',
    notify  => Service['kube-apiserver'],
  }

  ini_setting { 'kube_service_addresses setting':
    ensure  => present,
    path    => '/etc/kubernetes/apiserver',
    setting => 'KUBE_SERVICE_ADDRESSES',
    value   => '"--service-cluster-ip-range=10.254.0.0/16"',
    notify  => Service['kube-apiserver'],
  }

  ini_setting { 'kube_admission_control setting':
    ensure  => present,
    path    => '/etc/kubernetes/apiserver',
    setting => 'KUBE_ADMISSION_CONTROL',
    value   => '"--admission_control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ResourceQuota"',
    notify  => Service['kube-apiserver'],
  }

  ini_setting { 'kube_api_args setting':
    ensure  => present,
    path    => '/etc/kubernetes/apiserver',
    setting => 'KUBE_API_ARGS',
    value   => '""',
    notify  => Service['kube-apiserver'],
  }

  # Manage Services
  service { 'kube-controller-manager':
    ensure  => running,
    enable  => true,
    require => Package['kubernetes'],
  }

  service { 'kube-scheduler':
    ensure  => running,
    enable  => true,
    require => [Package['kubernetes'],Service['kube-controller-manager']],
  }

  service { 'kube-apiserver':
    ensure  => running,
    enable  => true,
    require => [Package['kubernetes'],Service['kube-scheduler']],
  }

}
