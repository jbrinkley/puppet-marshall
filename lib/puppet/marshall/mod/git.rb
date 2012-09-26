require 'puppet/marshall'

module Puppet::Marshall

    class Mod::Git < Mod

        def fetch
            @target = File.join(@settings.repository,
                           'modules', 'marshall', @name)
            if File.exist? @target and ! @settings['force-clean']
                @fetched = Puppet::Marshall::Git.open(@target)
                @fetched.pull
                @fetched.track_missing
            else
                # Create leading directories?
                @fetched = Puppet::Marshall::Git.clone(source, @target)
            end
            true
        end

        def implied_environments
            @fetched.local_branches.map do |branch|
                if branch == 'master'
                    @settings['default_environment'] || 'production'
                else
                    branch
                end
            end
        end

        def update(env=:all)
        end

    end

end
