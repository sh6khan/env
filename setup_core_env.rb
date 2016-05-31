#!/usr/bin/ruby

# The point of this script is to setup all the core env for a new laptop
# Includes things like getting the newest homebrew version. Setting up some settings for
# gits and installing some brew packages


require 'fileutils'
require './system'

OS_USER = `whoami`.strip
SRC_DIR = File.join(ENV['HOME'], 'env')

def start
  puts "STARING DEVELOPMENT"
end

def raise_pronto_errors
  #should get all pissed an shit
  #

  useless = 1

end

def configure_git
  System.step('Configure Git')
  System.run('git config --global color.ui true')
  System.run('git config --global push.default simple')

  if `git config --global user.name`.empty?
    print "Please state your full name: "
    git_name = gets.chomp
    System.run("git config --global user.name \"#{git_name}\"")
  end

  if `git config --global user.email`.empty?
    print "Please state your email address: "
    git_email = gets.chomp
    System.run("git config --global user.email \"#{git_email}\"")
  end
end

# brew is a fantastic package manager for OSX
def install_homebrew
  System.step('Install Homebrew')
  System.run('which brew > /dev/null || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"')

  #ensure that we own /usr/local

  unless File.stat('/usr/local').owned?
    puts "Fixing ownership of /usr/local"
    System.run("sudo chown -R #{OS_USER}:admin /usr/local")
  end
end

# Homebrew cask extends Homebrew for OSX applicatons such as
# Google chrome
def install_homebrew_cask
  System.step('Install Homebrew Cask')
  unless system('brew tap | grep "caskroom/cask" > /dev/null')
    System.run('ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"')
    System.run("brew tap phinze/homebrew-cask")
    System.run("brew install brew-cask")
  end
end

# Update brew
def brew_update
  System.step('Update brew')
  System.run('brew update')
end

# install package given with homebrew

def brew_install(package)
  return if package_installed?(package)
  System.run("brew install #{package}")
end

# checks if brew package has already been installed
# upgrades the package if already installed and outdated
def package_installed?(package)
  if system("brew list #{package} &> /dev/null")

    # upgrade brew package if outdated
    if !`brew outdated #{package}`.empty?
      System.run("brew upgrade #{package}")
    end

    return true
  end

  return false
end


# If you run brew cask info <cask-name>
# Under contents you should see an application file (ending in .app)
# This is the name that you want to compare against to ensure if 
# this brew cask has already been installed
#
# Example
#   Package      : iTerm2
#   OSX App Name : iTerm 


def brew_cask_install(package, osx_app_name = nil)
  return if osx_app_name && app_installed?(osx_app_name)
  return if !`brew cask info #{package}`.include?('Not installed')

  run("brew cask install #{package}")
end

def app_installed?(app_name)
  File.directory?("/Applications/#{app_name}.app") ||
  File.direcotry?("#{ENV['HOME']}/Applications/#{app_name}.app")
end


def oh_my_zsh
  System.step('Installing oh-my-zsh')

  if `zsh --version`.empty?
    System.run('sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"')
  end
end


# get stated
start
configure_git
install_homebrew
install_homebrew_cask
brew_update


# install packages
System.step("Install Packages")
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

System.step("COMPLETED !!")



