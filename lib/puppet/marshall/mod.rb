require 'puppet/marshall'

module Puppet::Marshall

    class Mod

        attr_accessor :name, :flavor, :style, :source

        def initialize(settings, fullname, opts)
            self.fullname = fullname
            @settings = settings
            set_from_opthash(opts)
            if @style.nil?
                if Puppet::Marshall::Git.is_git? @source
                    @style = 'git'
                else
                    @style = 'git'
                end
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

        def marshall
        end

        def update(env=:all)
        end

    end

end
