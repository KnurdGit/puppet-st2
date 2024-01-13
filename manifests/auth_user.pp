# @summary Creates and manages StackStorm application users (flat_file auth only)
#
# @param username 
#   Name of the user
# @param password
#   User's password
#
# @example Basic usage
#  st2::auth_user { 'st2admin':
#    password => 'neato!',
#  }
#
define st2::auth_user (
  $username = undef,
  $password = undef,
) {
  include st2::auth::flat_file
  $_htpasswd_file = $st2::auth::flat_file::htpasswd_file

  httpauth { $name:
    ensure    => present,
    password  => $password,
    mechanism => 'basic',
    file      => $_htpasswd_file,
    notify    => File[$_htpasswd_file],
  }

  ########################################
  ## Dependencies
  # TODO: Check if we really need this
  Package<| tag == 'st2::server::packages' |>
  -> Httpauth[$name]
  -> Service<| tag == 'st2::service' |>
}
