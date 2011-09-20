

class celery::rabbitmq($user="some_user",
                       $vhost="some_vhost",
                       $password="CHANGEME") {

  class { 'rabbitmq::repo::apt':
    pin    => 900,
    before => Class['rabbitmq::server']
  }

  class { 'rabbitmq::server':
    delete_guest_user => true,
  }

  rabbitmq_user { "$user":
    admin    => true,
    password => $password,
    provider => 'rabbitmqctl',
  }

  rabbitmq_vhost { $vhost:
    ensure => present,
    provider => 'rabbitmqctl',
  }

  rabbitmq_user_permissions { "$user@$vhost":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
    provider => 'rabbitmqctl',
  }
}

class celery::server($requirements="/tmp/vagrant-puppet/manifests/requirements.txt",
                     $user="some_user",
                     $vhost="some_vhost",
                     $password="CHANGEME",
                     $host="localhost",
                     $port="5672") {
  pip::install {"celery":
    requirements => $requirements,
    require => Exec["pip::bootstrapped"],
  }

  file { "/etc/default/celeryd":
    ensure => "present",
    content => template("celeryd"),
  }

  file { "/etc/init.d/celeryd":
    ensure => "present",
    content => template("init.d_celeryd"),
    mode => "0755",
  }

  user { "celery":
    ensure => "present",
  }

  file { "/var/celery":
    ensure => "directory",
    owner => "celery",
    require => User["celery"],
  }

  file { "/var/celery/celeryconfig.py":
    ensure => "present",
    content => template("celeryconfig.py"),
    require => File["/var/celery"],
  }

  file { "/var/log/celery":
    ensure => "directory",
    owner => "celery",
  }

  file { "/var/run/celery":
    ensure => "directory",
    owner => "celery",
  }

  service { "celeryd":
    ensure => "running",
    require => [File["/var/celery/celeryconfig.py"],
                File["/etc/init.d/celeryd"],
                Exec["pip-celery"],
                Class["rabbitmq::service"], ],
  }
}