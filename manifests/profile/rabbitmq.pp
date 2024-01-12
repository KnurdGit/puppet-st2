# @summary StackStorm compatable installation of RabbitMQ and dependencies.
#
# @param username
#   User to create within RabbitMQ for authentication.
# @param password
#   Password of +username+ for RabbitMQ authentication.
# @param port
#   Port to bind to for the RabbitMQ server
# @param bind_ip
#   IP address to bind to for the RabbitMQ server
# @param vhost
#   RabbitMQ virtual host to create for StackStorm
#
# @example Basic Usage
#   include st2::profile::rabbitmq
#
# @example Authentication enabled (configured vi st2)
#   class { 'st2':
#     rabbitmq_username => 'rabbitst2',
#     rabbitmq_password => 'secret123',
#   }
#   include st2::profile::rabbitmq
#
class st2::profile::rabbitmq (
  String  $username                       = $st2::rabbitmq_username,
  String  $password                       = $st2::rabbitmq_password,
  Integer $port                           = $st2::rabbitmq_port,
  String  $bind_ip                        = $st2::rabbitmq_bind_ip,
  String  $vhost                          = $st2::rabbitmq_vhost,
  Array   $erlang_url                     = $st2::erlang_url,
  String  $erlang_key                     = $st2::erlang_key,
  String  $erlang_key_id                  = $st2::erlang_key_id,
  String  $erlang_key_source              = $st2::erlang_key_source,
  String  $erlang_packages                = $st2::erlang_packages,
  String  $erlang_rhel_sslcacert_location = $st2::erlang_rhel_sslcacert_location,
  Integer $erlang_rhel_sslverify          = $st2::erlang_rhel_sslverify,
  Integer $erlang_rhel_gpgcheck           = $st2::erlang_rhel_gpgcheck,
  Integer $erlang_rhel_repo_gpgcheck      = $st2::erlang_rhel_repo_gpgcheck,
) inherits st2 {
  # RHEL 8 Requires another repo in addition to epel to be installed
  # TODO: I think we can use erlang module to manage this configuration
  if ($facts['os']['family'] == 'RedHat') {
    $repos_ensure = true

    # This is required because when using the latest version of rabbitmq because the latest version in EPEL
    # for Erlang is 22.0.7 which is not compatible: https://www.rabbitmq.com/which-erlang.html
    yumrepo { 'erlang':
      ensure        => present,
      name          => 'rabbitmq_erlang',
      baseurl       => $erlang_url,
      gpgkey        => $erlang_key,
      enabled       => 1,
      gpgcheck      => $erlang_rhel_gpgcheck,
      repo_gpgcheck => $erlang_rhel_repo_gpgcheck,
      before        => Class['rabbitmq::repo::rhel'],
      sslverify     => $erlang_rhel_sslverify,
      sslcacert     => $erlang_rhel_sslcacert_location,
    }
  }
  elsif ($facts['os']['family'] == 'Debian') {
    $repos_ensure = true
    # trusty, xenial, bionic, etc
    $release = downcase($facts['os']['distro']['codename'])
    $repos = 'main'

    apt::source { 'erlang':
      ensure   => 'present',
      location => $erlang_url,
      release  => $release,
      repos    => $repos,
      pin      => '1000',
      key      => {
        'id'     => $erlang_key_id,
        'source' => $erlang_key_source,
      },
      notify   => Exec['apt-get-clean'],
      tag      => ['st2::rabbitmq::sources'],
    }
    # rebuild apt cache since we just changed repositories
    # Executing it manually here to avoid dep cycles
    exec { 'apt-get-clean':
      command     => '/usr/bin/apt-get -y clean',
      refreshonly => true,
      notify      => Exec['apt-get-update'],
    }
    exec { 'apt-get-update':
      command     => '/usr/bin/apt-get -y update',
      refreshonly => true,
    }
    package { $erlang_packages:
      ensure  => 'present',
      tag     => ['st2::packages', 'st2::rabbitmq::packages'],
      require => Exec['apt-get-update'],
    }
  }
  else {
    $repos_ensure = false
  }

  # TODO: Use rabbitmq module to manage all of this
  # In new versions of the RabbitMQ module we need to explicitly turn off
  # the ranch TCP settings so that Kombu can connect via AMQP
  class { 'rabbitmq' :
    config_ranch          => false,
    repos_ensure          => $repos_ensure,
    delete_guest_user     => true,
    port                  => $port,
    environment_variables => {
      'RABBITMQ_NODE_IP_ADDRESS' => $st2::rabbitmq_bind_ip,
    },
    manage_python         => false,
  }
  contain 'rabbitmq'

  rabbitmq_user { $username:
    admin    => true,
    password => $password,
  }

  rabbitmq_vhost { $vhost:
    ensure => present,
  }

  rabbitmq_user_permissions { "${username}@${vhost}":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }

  # RHEL needs EPEL installed prior to rabbitmq
  if $facts['os']['family'] == 'RedHat' {
    Class['epel']
    -> Class['rabbitmq']

    Yumrepo['epel']
    -> Class['rabbitmq']

    Yumrepo['epel']
    -> Package['rabbitmq-server']
  }
  # Debian/Ubuntu needs erlang before rabbitmq
  elsif $facts['os']['family'] == 'Debian' {
    Package<| tag == 'st2::rabbitmq::packages' |>
    -> Class['rabbitmq']
  }
}
