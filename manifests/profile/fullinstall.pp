# @summary This class performs a full default install of StackStorm and all its components on a single node.
#
# Components:
#  * RabbitMQ
#  * Python
#  * MongoDB
#  * NodeJS
#  * nginx
#
# @example Basic Usage
#   include st2::profile::fullinstall
#
# @example Customizing parameters
#   # Customizations are done via the main st2 class
#   class { 'st2':
#     # ... assign custom parameters
#   }
#
#   include st2::profile::fullinstall
#
class st2::profile::fullinstall inherits st2 {
  contain 'st2::profile::facter'
  contain 'st2::repo'
  contain 'st2::profile::selinux'
  contain 'st2::profile::redis'
  contain 'st2::profile::python'
  contain 'st2::profile::nodejs'
  contain 'st2::profile::rabbitmq'
  contain 'st2::profile::mongodb'
  contain 'st2::profile::client'
  contain 'st2::profile::server'
  contain 'st2::profile::web'
  contain 'st2::profile::chatops'

  Class['st2::profile::facter']
  -> Class['st2::repo']
  -> Class['st2::profile::selinux']
  -> Class['st2::profile::redis']
  -> Class['st2::profile::python']
  -> Class['st2::profile::nodejs']
  -> Class['st2::profile::rabbitmq']
  -> Class['st2::profile::mongodb']
  -> Class['st2::profile::client']
  -> Class['st2::profile::server']
  -> Class['st2::profile::web']
  -> Class['st2::profile::chatops']

  include st2::auth
  include st2::packs
  include st2::kvs

  # If user has not defined a pack "st2", install it from the Exchange.
  # TODO:  Check if we can remove this and just always install st2 pack
  if ! defined(St2::Pack['st2']) {
    ensure_resource('st2::pack', 'st2', { 'ensure' => 'present' })
  }
}
