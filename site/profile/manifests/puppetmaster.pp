class profile::puppetmaster {

  $hiera_yaml = "${::settings::confdir}/hiera.yaml"

  class { 'hiera':
    hierarchy  => [
      'virtual/%{::virtual}',
      'nodes/%{::trusted.certname}',
      'common',
    ],
    hiera_yaml => $hiera_yaml,
    datadir    => '/etc/puppetlabs/code/environments/%{environment}/hieradata',
    owner      => 'pe-puppet',
    group      => 'pe-puppet',
    notify     => Service['pe-puppetserver'],
  }

  ini_setting { 'puppet.conf hiera_config main section' :
    ensure  => present,
    path    => "${::settings::confdir}/puppet.conf",
    section => 'main',
    setting => 'hiera_config',
    value   => $hiera_yaml,
    notify  => Service['pe-puppetserver'],
  }

  ini_setting { 'puppet.conf hiera_config master section' :
    ensure  => absent,
    path    => "${::settings::confdir}/puppet.conf",
    section => 'master',
    setting => 'hiera_config',
    value   => $hiera_yaml,
    notify  => Service['pe-puppetserver'],
  }

  #remove the default hiera.yaml from the code-staging directory
  #after the next code manager deployment it should be removed
  #from the live codedir
  file { '/etc/puppetlabs/code-staging/hiera.yaml' :
    ensure => absent,
  }

  file { '/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa':
    ensure => present,
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
  }
  file { '/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub':
    ensure => present,
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
  }

  file { '/etc/puppetlabs/puppetserver/ssh':
    ensure => present,
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
  }

  package { 'gcc-c++':
    ensure => present,
  }->
  package { 'activesupport':
    ensure   => present,
    provider => puppetserver_gem,
  }->
  package { 'kubeclient':
    ensure   => present,
    provider => puppetserver_gem,
  }

  $kube_master_ip = generate('/bin/sh', '-c', '/bin/ping -c 1 kubernetes_master | /bin/head -1 | /bin/cut -d")" -f 1 | /bin/cut -d"(" -f 2')
  notify { "the value is ${kube_master_ip}": }
  file { '/etc/puppetlabs/puppet/kubernetes.conf':
    ensure  => present,
    content => template('profile/kubernetes.conf.erb'),
  }

}
