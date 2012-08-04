puppet-marshall
===============

Bootstrapping live Puppet configuration by assembling separately-developed modules

The goal of this project is to allow you to marshall a complete puppet manifest by indicating the location of the various modules you want to assemble. A bootstrapping script creates global manifests and configurations allowing the configuration to be served by a puppetmaster or applied standalone.

Roadmap
-------

The initial planned version is _n_:

### Version n

* Provide a single command which accepts the following in configuration
    * Credentials (ssh private keys, X.509 certificates, username:password pairs)
    * Module meta-manifest (list of modules and git URLs)
	 * How environments should be created (automatically by branches?)
	 * Post-marshalling hook (for example, to reload a Puppetmaster)

* Features
    * For each module listed in the MMM, retrieves or updates the "checked-out" module
    * Uses credentials as needed
    * 

Configuration example:

    { "repository": "/etc/puppet"
	 	"styles": ["standalone", "puppetmaster"],
      "modules": {
        "puppetlabs/stdlib": "forge",
        "puppetlabs-openstack": "https://github.com/puppetlabs/puppetlabs-openstack.git",
		  "apache": {
          "style": "forge",
          "name": "puppetlabs/apache",
          "version": "0.0.3"
        }
		  "our/webserver": "git+ssh://my.gitserver.com/webserver.git"
      }
      "overlay": "git+ssh://my.gitserver.com/puppet.git"
      "credentials": {
         "git+ssh": "private-key",
      }
    }

With the above configuration in puppet-marshall.conf, running `puppet-marshall puppet-marshall.conf` would result in:

* A clone of `git+ssh://my.gitserver.com/puppet.git` in `/etc/puppet`.
* A `puppetmaster.conf` resulting from expanding the `puppetmaster.conf.erb` in the overlay to include any required environment module paths (style `puppetmaster`)
* A `bootstrap.pp` file usable for running `puppet apply bootstrap.pp`
* Subdirectories of `modules/` containing the modules `stdlib`, `puppetlabs-openstack` and `apache`, downloaded from the appropriate locations if necessary (or updated)

### Version n+1

* Other module locations

Assumptions/Dependencies
------------------------

* ruby
* facter
* puppet
