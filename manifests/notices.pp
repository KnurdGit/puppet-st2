# @summary This is a private class used to store long strings to limit down on lint problems.
# @note Please do not call directly
#
class st2::notices {
  include 'st2::params'

  $user_missing_client_keys = @("EOF"/L)
    ssh_public_key and ssh_key_type need to be supplied for this resource.
    Help can be found in INSTALL.md if needed
    |-EOF

  $user_missing_private_key = 'ssh_private_key needs to be supplied for this resource. Help can be found in INSTALL.md if needed'
  $unsupported_os = 'Your platform is not yet supported. Please file a bug or submit a bug to https://github.com/StackStorm/st2'
  $auth_test_user_enabled = 'The test user for the WebUI is **ENABLED**. Ensure to disable before deploying to production'
  $web_no_oauth_token =  @("EOF"/L)
    The Web Interface is currently in limited beta.
    You will need a key to test this out.
    Please email us at support@stackstorm.com if you are interested in trying it
    out and providing feedback
    |-EOF
}
