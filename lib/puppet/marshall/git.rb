#ruby

require 'fileutils'
require 'puppet/marshall'
require 'puppet/marshall/error'

module Puppet::Marshall

    class Git

        @@dbg = false

        attr_accessor :repo
        # TODO: authentication (also not provided in git module)

        def initialize(repo, opts={})
            @repo = repo
        end

        def self.open(repo, opts={})
            self.new(repo, opts)
        end

        def self.set_debug
            @@dbg = true
        end

        def self.log(msg)
            if @@dbg
                File.open('puppet-marshall-git-debug.log', 'a') do |fh|
                    fh.puts msg
                end
            end
        end

        def self.dbg(msg)
            if @@dbg
                puts "DBG(Puppet::Marshall::Git): #{msg}"
            end
        end

        def self.is_git?(url)
            case url
            when /\.git$/
                true
            when /^git/
                true
            else
                # Really, 'unknown' or 'not for sure'
                false
            end
        end

        def dbg(msg)
            self.class.dbg(msg)
        end

        def self.command(repodir, command, *args)
            cmd = ['git', command] + args
            dbg "Command line: #{cmd.join(' ')}"
            out = [ ]
            IO.popen('-') do |io|
                if io.nil?
                    # Child
                    log "Child is #{Process.pid}"
                    Dir.chdir repodir unless repodir.nil?
                    log "   redirecting $stderr"
                    $stderr.reopen($stdout)
                    log "   exec(#{cmd.join(', ')})"
                    exec *cmd
                    log "   exec failed"
                end
                dbg "Parent is #{Process.pid}"
                out = io.readlines
                dbg "   read #{out.size} lines"
            end
            dbg "   read: ``" + out.join("\n   ") + "''"
            if $?.exitstatus != 0
                raise Puppet::Marshall::Error.new("Error running command: " +
                                              "#{cmd.join(' ')}: " +
                                              "#{out.join('')}")
            end
            out
        end

        # clones a repository from the given source
        # @param source [String] the git URL or repository location
        # @param destdir [String] the destination directory
        # @param branch [String] the name of the branch to checkout
        # @return [Puppet::Marshall::Git] the new repository
        def self.clone(source, destdir, branch=nil)
            # git clone --branch #{branch}
            # That does not seem to work as you would want
            # that is it doesn't check it out
            # should that happen here?
            cmd = ['clone']
            unless branch.nil?
                cmd << '--branch'
                cmd << branch
            end
            cmd << source
            cmd << destdir
            self.command(nil, *cmd)
            git = self.new destdir
            git.pull
            unless branch.nil?
                git.checkout branch
            end
            git
        end

        # clones the opened repository
        # @param destdir [String] the destination directory
        # @param branch [optional, String
        # @return [Puppet::Marshall::Git] the new repository
        def clone(destdir, branch=nil)
            self.class.clone(self.repo, destdir, branch)
        end

        def command(*args)
            self.class.command(self.repo, *args)
        end

        # updates the repository from its remote
        # Note: does not set up tracking branches (see track_missing)
        def pull(branch=nil)
            # git pull --all
            command('pull', '--all')
            track_missing
            unless branch.nil?
                checkout branch
            end
            true
        end

        def checkout(branch)
            if branch.nil?
                $stderr.puts("warning checkout nil called")
            else
                dbg "checkout #{branch.inspect}"
                command('checkout', branch)
            end
        end

        # lists local branches
        def local_branches
            # git branch --list
            output = command('branch', '--list')
            output.map { |b| b.sub(/\*/, '').strip }
        end

        # tracks specific local branch (but see track_missing)
        def track(branch)
            # git branch --track <branch>
            command('branch', '--track', branch)
        end

        # sets up local tracking branches for all remote branches
        # and pulls if necessary. Can result in two pulls--one at
        # the beginning, then another if a new branch was set up
        def track_missing
            lbranches = local_branches
            dbg "track_missing: local branches = #{lbranches.join(', ')}"
            remote = remote_name
            added = []
            remote_branches.reject { |b| /HEAD/.match(b) }.each do |branch|
                dbg "   considering remote branch #{branch}"
                lbranch = branch.sub(/^#{remote}\//, '')
                dbg "   local branch name would be #{lbranch}"
                unless lbranches.include? lbranch
                    dbg "   not already tracking #{lbranch}"
                    added << lbranch
                    track lbranch
                end
            end
            added
        end

        # lists remote branches
        def remote_branches
            # git branch --remote
            output = command('branch', '--remote')
            output.map { |rb| rb.strip }
        end

        # lists the name of the remote
        def remote_name
            # git remote
            command('remote')[0].strip
        end
    end

end
