require 'puppet/marshall'

module Puppet::Marshall

    class Mod

        attr_accessor :name, :flavor, :style, :source

        def self.get_instance(settings, fullname, opts)
            if opts[:style].nil?
                if Puppet::Marshall::Git.is_git? opts[:source]
                    opts[:style] = 'git'
                else
                    opts[:style] = 'git'
                end
            end
            case opts[:style]
            when 'git'
                require 'puppet/marshall/mod/git'
                Puppet::Marshall::Mod::Git.new(settings, fullname, opts)
            else
                raise Puppet::Marshall::Error.new(
                                              "Unsupported style #{opts[:style]}")
            end
        end

        def initialize(settings, fullname, opts)
            self.fullname = fullname
            @settings = settings
            set_from_opthash(opts)
            valid?
        end

        def source_valid?
            "no source given for module #{@name}" if @source.nil?
        end

        def valid?
            errs = [ ]
            self.methods.each do |methodname|
                if /_valid\?$/.match(methodname)
                    err = self.send(methodname)
                    errs << err if err
                end
            end
            if errs.size > 0
                raise Puppet::Marshall::Error.new(
                                              "errors for module #{@name}: " +
                                              errs.join("; "))
            end
        end

        def fullname=(fname)
            @fullname = fname
            @name = fname.split('/')[-1]
            @fullname
        end

        def fullname
            @fullname
        end

        # fetches/updates/syncs info from source but does not update puppet
        def fetch
            false
        end

        # returns the list of live environments based on the source
        def implied_environments
            []
        end

        # fetches, then
        # updates live puppet for the environments specified
        def update(env=:all)
            []
        end

    end

end
