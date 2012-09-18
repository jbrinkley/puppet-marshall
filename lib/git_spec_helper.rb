#!ruby
# -*- mode: ruby -*-

require 'puppet/marshall/git'

$master_content = <<'EOF'
class testmod {
   file {
      "testmod-indicator":
         path => "/var/tmp/testmod.indicator",
         content => "testmod\n",
         owner => 'root',
         group => 'root',
         mode => 0644;
   }
}
EOF

$staging_content = <<'EOF'
class testmod {
   file {
      "testmod-indicator":
         path => "/var/tmp/testmod.indicator",
         content => "testmod staging\n",
         owner => 'root',
         group => 'root',
         mode => 0644;
   }
}
EOF

$staging_update = <<'EOF'
class testmod {
   file {
      "testmod-indicator":
         path => "/var/tmp/testmod.indicator",
         content => "testmod staging update\n",
         owner => 'root',
         group => 'root',
         mode => 0644;
   }
}
EOF

$user_content = <<'EOF'
class testmod {
   file {
      "testmod-indicator":
         path => "/var/tmp/testmod.indicator",
         content => "testmod user\n",
         owner => 'root',
         group => 'root',
         mode => 0644;
   }
}
EOF

def filecontent(file)
    File.open(file, 'r') { |fh| fh.read }
end

RSpec.configure do |config|

    config.before(:all) do
        FileUtils.rm_r "test/data" if File.exist? "test/data"
        if File.exist? "test/fixture"
            FileUtils.cp_r "test/fixture"
        else
            FileUtils.mkdir "test/data"
        end
        Dir.chdir "test/data" do
            system "git init testmod"
            Dir.chdir "testmod" do
                system "git config --local user.name \"Tester\""
                system "git config --local user.email \"test@test.test\""
                FileUtils.mkdir "manifests"
                File.open("manifests/testmod.pp", 'w') do |fh|
                    fh.print $master_content
                end
                system "git add manifests"
                system "git commit -m\"initial commit\""
                system "git branch staging"
                system "git checkout staging"
                File.open("manifests/testmod.pp", 'w') do |fh|
                    fh.print $staging_content
                end
                system "git add manifests/testmod.pp"
                system "git commit -m\"add staging version\""
                system "git checkout master"
            end
        end

    end

    config.after(:all) do
        FileUtils.rm_r "test/data" if File.exist? "test/data"
    end

end
