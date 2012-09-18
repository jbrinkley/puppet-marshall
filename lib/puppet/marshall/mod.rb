require 'puppet/marshall'

module Puppet::Marshall

    class Mod

        attr_accessor :name, :fullname, :flavor, :style, :source

        def initialize(settings, opts)
            @settings = settings
            set_from_opthash(opts)
        end

        def marshall
        end

        def update(env=:all)
        end

    end

end
