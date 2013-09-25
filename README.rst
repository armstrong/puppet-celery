celery for puppet
=================
This installs and configures `Celery`_.

Usage
-----
Make sure this module is available by adding this repository's contents
in a directory called ``celery`` inside your Puppet's ``moduledir``.
It also requires the `puppet-python`_ module as well.


Bootstrapping RabbitMQ
""""""""""""""""""""""
If you need to bootstrap RabbitMQ ::

    class { "celery::rabbitmq": }

You should provide a ``user``, ``vhost``, and ``password`` along these
lines::

    class { "celery::rabbitmq":
      $user => "myuser",
      $vhost => "myvhost",
      $password => "secret",
    }

This installs and configures RabbitMQ.  Take a look at
`puppetlabs-rabbitmq`_ if you need more flexibility in how your RabbitMQ
instance is initialized.

Creating Celery Server
""""""""""""""""""""""
You create a celery server with the ``celery::server`` class like this::

    class { "celery::server": }

If you're relying on the RabbitMQ bootstrap, you would set it up like this::

    class { "celery::server":
      require => Class["celery::rabbitmq"],
    }

Configuration
-------------
*TODO*


.. _Celery: http://celeryproject.org/
.. _puppet-python: https://github.com/stankevich/puppet-python
.. _distribute: http://packages.python.org/distribute/
.. _pip: http://www.pip-installer.org/
.. _puppet: http://puppetlabs.com/
.. _puppet-pip: https://github.com/armstrong/puppet-pip
.. _puppetlabs-rabbitmq: https://github.com/puppetlabs/puppetlabs-rabbitmq/
.. _this version: https://github.com/puppetlabs/puppetlabs-rabbitmq/pull/8
