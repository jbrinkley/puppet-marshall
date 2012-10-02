require 'puppet/marshall'

module Puppet::Marshall

    class Mod::Git < Mod

        def fetch
            @target = File.join(@settings.repository,
                           'modules', 'marshall', @name)
            @fetched = open_or_clone(@source, @target)
            true
        end

        def implied_environments
            @fetched.local_branches.map { |branch| env_for branch }
        end

        def branch_for(env)
            if env == (@settings['default_environment'] || 'production')
                'master'
            else
                env
            end
        end

        def env_for(branch)
            if branch == 'master'
                @settings['default_environment'] || 'production'
            else
                branch
            end
        end

        # What about different workflows? tags or commits for environments
        # for example?
        def update(env=:all)
            dbg "Puppet::Marshall::Mod::Git#update(#{env.inspect})"
            fetch
            case env
            when :all
                implied_environments.each { |e| update e }
            when *implied_environments
                do_update(env)
            else
                # should raise or warn?
                raise Puppet::Marshall::Error.new("No environment '#{env}' implied in source")
            end
        end

        # Not part of the interface - all interface methods in this class
        # specify environments, not branches
        def open_or_clone(source, loc, branch=nil)
            dbg "open_or_clone(#{source.inspect}, #{loc.inspect}, #{branch.inspect})"
            if File.exist? loc and ! @settings['force-clean']
                fetched = Puppet::Marshall::Git.open(loc)
                # Hm, this doesn't seem right. Don't I need to create the
                # local tracking branch before checking it out? that is,
                # don't I need to separate the pull and checkout here?
                fetched.pull branch
            else
                # Create leading directories?
                fetched = Puppet::Marshall::Git.clone(source, loc, branch)
            end
            fetched
        end

        def do_update(env)
            module_loc = File.join(@settings.repository, 'modules', env,
                              @name)
            updated = open_or_clone(@target, module_loc, branch_for(env))
        end
    end

end
