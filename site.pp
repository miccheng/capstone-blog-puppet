## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# PRIMARY FILEBUCKET
# This configures puppet agent and puppet inspect to back up file contents when
# they run. The Puppet Enterprise console needs this to display file contents
# and differences.

# Define filebucket 'main':
filebucket { 'main':
  server => 'master.puppetlabs.vm',
  path   => false,
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }
  notify { "Hello ${fqdn}": }

  $vhostname = "capstone.two.puppetlabs.vm"

  host { $vhostname :
    ip => $::ipaddress
  }

  class {'apache': }
  class {'apache::mod::php': }
  apache::vhost { $vhostname:
        priority      => '10',
        vhost_name    => $::ipaddress,
        port          => '80',
        docroot       => '/var/www/wordpress/',
        logroot       => '/var/log/httpd/',
        serveradmin   => 'teamtwo@puppetlabs.com',
  }

  class { 'mysql': }
  class { 'mysql::server':
    config_hash => { 'root_password' => 'foo321' }
  }
  class { 'mysql::php': }

  class { 'vsftpd':
    anonymous_enable  => 'NO',
    write_enable      => 'YES',
    ftpd_banner       => 'Capstone Two FTP Server',
    #chroot_local_user => 'YES',
  }

  user { "wordpress" :
    ensure   => present,
    password => '$1$tDyCU5xF$ucq5iIwwv06chQjoBaPBU1',
    gid      => 'wordpress',
    shell    => '/bin/bash',
    home     => '/home/wordpress',
  }

  group { "wordpress":
    ensure => present
  }

  class { 'wordpress':
    wp_owner    => 'wordpress',
    wp_group    => 'wordpress',
    db_password => 'foo123',
    install_dir => '/var/www/wordpress',
    require     => Class['mysql::server']
  }

}
