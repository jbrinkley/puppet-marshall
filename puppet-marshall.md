
NAME
====

puppet-marshall - Bring together puppet modules from various sources

SYNOPSIS
========

    puppet-marshall [options] manifest.json [update-spec [...]]
        --clean-update - do not use cached (marshalled) module copies
        update-spec:
            <module>        - update only named module
            module.<module> - update only named module
            global.<option> - update only global option (for example,
                              the environment list)

DESCRIPTION
===========

The **puppet-marshall** program collects Puppet modules into a Puppet
repository so that `puppet apply` or `puppet master` can read them to compile
a catalog. It also maintains the up-to-date-ness of the Puppet module(s) as
directed in an optimal or on-demand way. Secondarily, it provides a way to
generate and/or check out the "global" Puppet level in the form of
`puppet.conf` or other files or an overlay checkout.

Modules, Environments and Use Cases
-----------------------------------

The **puppet-marshall** program is designed to be most useful in an setting
where _environment_ is used and it's desired that environments correspond with
branches in a version control system and inherit from each other.

In other words, let's say the **webserver** module comes from a git repository
at `https://git.mycompany.ex/webserver.git`. When developers want to make a
new version of this module, they create a branch named after themselves and
work on it, testing servers in their own environment repeatedly. When they are
satisfied, the work is merged to another branch for testing, and finally to
production.

The **puppet-marshall** program facilitates this workflow by automatically
understanding that each branch in the git repository should correspond to an
environment in the Puppet configuration--namely a subdirectory of `modules/`
so that each environment has its own **module_path**.

Manifest File
-------------

The manifest file is a JSON-serialized object. Each key in the object
describes a configuration attribute; the most important is **module**, which
configures the list of modules and their sources from which
**puppet-marshall** will build the Puppet configuration.

Module Sources
--------------

* git
* subversion
* forge (PuppetForge)
* archive (possibly tarballs at a given URL)

EXAMPLES
========

AUTHOR
======

Jeremy Brinkley, <jbrinkley@proofpoint.com>
