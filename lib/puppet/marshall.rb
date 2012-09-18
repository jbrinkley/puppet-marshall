class Object
    def set_from_opthash(opts)
        self.methods.each do |methodname, acc|
            smethodname = methodname.to_s
            if smethodname[-1] == ?=
                optkey = smethodname[0 .. -2].to_sym
                self.send(methodname, opts[optkey]) if opts.has_key? optkey
            end
        end
    end
end

module Puppet

    module Marshall


    end

end
