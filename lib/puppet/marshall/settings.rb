#!ruby

require 'puppet/marshall'

module Puppet::Marshall

    class Settings < Hash

        def repository
            self[:repository]
        end

        def repository=(loc)
            self[:repository] = loc
        end

    end

end
