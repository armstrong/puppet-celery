

class celery::rabbitmq($user="some_user",
                       $vhost="some_vhost",
                       $password="CHANGEME") {

  # rabbitmq module needs this
  package {'curl':
    ensure => present,
  } ->
  class { '::rabbitmq':
    package_apt_pin => 900,
    # use this for the time being remove once working
    delete_guest_user => false,
  }

  rabbitmq_user { $user:
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

class celery::server($venv="system-wide",
                     $django_name="",
                     $proroot="",
                     $venvowner="root",
                     $requirements="/tmp/celery-requirements.txt",
                     $requirements_template="celery/requirements.txt",
                     $initd_template="celery/init.d.sh",
                     $defaults_template="celery/celery_defaults.sh.erb",
                     $broker_user="some_user",
                     $broker_vhost="some_vhost",
                     $broker_password="CHANGEME",
                     $broker_host="localhost",
                     $broker_port="5672") {

  file { $requirements:
    ensure => "present",
    content => template($requirements_template),
  }

  file { "/etc/default/celeryd":
    ensure => "present",
    content => template($defaults_template),
  }

  file { "/etc/init.d/celeryd":
    ensure => "present",
    content => template($initd_template),
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

  file { "/var/log/celery":
    ensure => "directory",
    owner => "celery",
  }

  file { "/var/run/celery":
    ensure => "directory",
    owner => "celery",
  }

  python::requirements { $requirements:
    virtualenv => $venv,
    owner => $venvowner,
    group => $venvowner,
  } ->
  service { "celeryd":
    hasrestart => true,
    ensure => "running",
    require => [File["/etc/init.d/celeryd"],
                File["/etc/default/celeryd"],
                File["/var/log/celery"],
                File["/var/run/celery"],
                Class["rabbitmq::service"], ],
  }
}
