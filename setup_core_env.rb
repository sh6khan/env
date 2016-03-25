#!/usr/bin/ruby

# The point of this script is to setup all the core env for a new laptop
# Includes things like getting the newest homebrew version. Setting up some settings for
# gits and installing some brew packages


require 'fileutils'

OS_USER = `whomai`.strip
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


