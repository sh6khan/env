#!/usr/bin/ruby

# The point of this script is to setup all the core env for a new laptop
# Includes things like getting the newest homebrew version. Setting up some settings for
# gits and installing some brew packages


require 'fileutils'

OS_USER = `whoami`.strip
SRC_DIR = File.join(ENV['HOME'], 'env')

def start
  puts "STARING DEVELOPMENT"
end

def step(name)
  print "====> #{name}\n"
end

def run(cmd)
  unless system(cmd)
    abort ("Command `#{cmd}` failed with status #{$?.exitstatus}")
  end
end


def configure_git
  step('Configure Git')
  run('git config --global color.ui true')
  run('git config --global push.default simple')

  if `git config --global user.name`.empty?
    print "Please state your full name: "
    git_name = gets.chomp
    run("git config --global user.name \"#{git_name}\"")
  end

  if `git config --global user.email`.empty?
    print "Please state your email address: "
    git_email = gets.chomp
    run("git config --global user.email \"#{git_email}\"")
  end
end

# brew is a fantastic package manager for OSX
def install_homebrew
  step('Install Homebrew')
  run('which brew > /dev/null || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"')

  #ensure that we own /usr/local

  unless File.stat('/usr/local').owned?
    puts "Fixing ownership of /usr/local"
    run("sudo chown -R #{OS_USER}:admin /usr/local")
  end
end

# Homebrew cask extends Homebrew for OSX applicatons such as
# Google chrome
def install_homebrew_cask
  step('Install Homebrew Cask')
  unless system('brew tap | grep "caskroom/cask" > /dev/null')
    run('brew install caskroom/cask/brew-cask')
  end
end

# Update brew
def brew_update
  step('Update brew')
  run('brew update')
end

# install package given with homebrew

def brew_install(package)
  return if package_installed?(package)
  run("brew install #{package}")
end

# checks if brew package has already been installed
# upgrades the package if already installed and outdated
def package_installed?(package)
  if system("brew list #{package} &> /dev/null")

    # upgrade brew package if outdated
    if !`brew outdated #{package}`.empty?
      run("brew upgrade #{package}")
    end

    return true
  end

  return false
end


def brew_cask_install(package, osx_app_name = nil)
  return if osx_app_name && app_installed?(osx_app_name)
end

def app_installed?(app_name)
  File.directory?("/Applications/#{app_name}.app") ||
  File.direcotry?("#{ENV['HOME']}/Applications/#{app_name}.app")
end


def oh_my_zsh
  step('Installing oh-my-zsh')
  if `zsh --version`.empty?
    puts "zsh is not installed"
    return
  end

  # checks if oh-my-zsh is already installed
  shell = `echo $SHELL`
  return if shell == "/bin/zsh"
  
  run('sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"')
end


# get stated
start
configure_git
install_homebrew
install_homebrew_cask
brew_update


# install packages
step("Install Packages")
brew_install('bash-completion')
brew_install('git')
brew_install('wget')
brew_install('vim')
brew_install('ctags')
brew_install('node')
brew_install('keybase')
brew_install('redis')

brew_cask_install('iterm2', 'iTerm')

# bash_profile and themes and zsh
oh_my_zsh

step("COMPLETED !!")



