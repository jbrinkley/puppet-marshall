require 'puppet/marshall'

module Puppet::Marshall

    class Mod

        attr_accessor :name, :flavor, :style, :source

        def initialize(settings, fullname, opts)
            self.fullname = fullname
            @settings = settings
            set_from_opthash(opts)
            # Calculate source if possible - TODO
            if @style.nil?
                if Puppet::Marshall::Git.is_git? @source
                    @style = 'git'
                else
                    @style = 'git'
                end
            end
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

        def marshall
        end

        def update(env=:all)
        end

    end

end
