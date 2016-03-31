# all system commands such as git clone

require 'fileutils'

module System
  OS_USER = `whoami`.strip

  def self.step(step)
    puts "====> #{step}"
  end

  def self.run(cmd)
    unless system(cmd)
      abort("Command `#{cmd}` failed with status #{$?.exitstatus}")
    end
  end

  def self.git_clone(repo, target, name = nil)
    name ||= repo
    step("cloning #{name}")

    target = build_proper_target(target)

    if Dir.exists?(target)
      #ensure correct git remote
      Dir.chdir(target) do
        unless `git remote -v | grep "^origin\\s" | cut -f2`.include?(repo)
          system("git remote rm origin 2> /dev/null")
          run("git remote add origin #{source}")
        end

        run("git fetch")
      end
    else
      #clone
      run("git clone #{repo} #{target}")
    end
  end


  # fileutils doesnt recoginize shortcuts such as ~
  # therefore we have to replace that with ENV['HOME']

  def self.build_proper_target(target)
    if target[0] == "~"
      target[0] = ENV['HOME']
    end

    target
  end
end
