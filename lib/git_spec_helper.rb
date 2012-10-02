#!ruby
# -*- mode: ruby -*-

$debugout = ENV['TEST_DEBUG'] ? '' : '>/dev/null 2>&1'

require 'puppet/marshall/git'
Puppet::Marshall::Git.set_debug if ENV['TEST_DEBUG']

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

$updated_content = <<'EOF'
class testmod {
   file {
      "testmod-indicator":
         path => "/var/tmp/testmod.indicator",
         content => "testmod updated\n",
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

def content(str)
    <<"EOF"
class testmod {
   file {
      "testmod-indicator":
          path => "/var/tmp/testmod.indicator",
          content => "#{str}\n",
          owner => 'root',
          group => 'root',
          mode => 0644;
   }
}
EOF
end

def makebranch(branch, content=$user_content)
    Dir.chdir("test/data/testmod") do
        system "git branch #{branch} #{$debugout}"
        system "git checkout #{branch} #{$debugout}"
        File.open("manifests/testmod.pp", 'w') do |fh|
            fh.print content
        end
        system "git add manifests/testmod.pp #{$debugout}"
        system "git commit -m\"update #{branch} content\" #{$debugout}"
    end
end

def updatemaster(content=$updated_content)
    Dir.chdir("test/data/testmod") do
        system "git checkout master #{$debugout}"
        File.open("manifests/testmod.pp", 'w') do |fh|
            fh.print content
        end
        system "git add manifests/testmod.pp #{$debugout}"
        system "git commit -m\"update master content\" #{$debugout}"
    end
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
            system "git init testmod #{$debugout}"
            Dir.chdir "testmod" do
                system "git config --local user.name \"Tester\" #{$debugout}"
                system "git config --local user.email \"test@test.test\" #{$debugout}"
                FileUtils.mkdir "manifests"
                File.open("manifests/testmod.pp", 'w') do |fh|
                    fh.print $master_content
                end
                system "git add manifests #{$debugout}"
                system "git commit -m\"initial commit\" #{$debugout}"
                system "git branch staging #{$debugout}"
                system "git checkout staging #{$debugout}"
                File.open("manifests/testmod.pp", 'w') do |fh|
                    fh.print $staging_content
                end
                system "git add manifests/testmod.pp #{$debugout}"
                system "git commit -m\"add staging version\" #{$debugout}"
                system "git checkout master #{$debugout}"
            end
        end

    end

    config.after(:all) do
        # It would be nice to examine exceptions and leave this here for
        # errors
        unless ENV['TEST_DEBUG']
            FileUtils.rm_r "test/data" if File.exist? "test/data"
        end
    end

end
