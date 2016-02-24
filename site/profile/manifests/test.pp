class profile::test {


  kubernetes_pod { 'owncloud-pod':
    ensure      => present,
    metadata    => { namespace => 'default',},
    spec         => {
      containers => [{
          name     => 'owncloud-app',
          image    => 'owncloud',
        },
        {
          name    => 'mysql-db',
          image   => 'mysql',
          env     => {
            name  => 'MYSQL_ROOT_PASSWORD',
            value => 'secret',
          }
        }
      ]
    },
  }
}
