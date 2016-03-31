# this script is used to create the directory structure for my personal setup
# The idea would be that this repo would be cloned into the home directory of the user
#
# all the aliases and profile will exist in this project. Therfore when we link
# aliases in the directory to the .zshrc file it will have a path come directly 
# to the aliases file in this directory

# TODO : everything else .. :(


require 'fileutils'


def run(cmd)
  unless system(cmd)
    abort("Command `#{cmd}` failed with status #{$?.exitstatus}")
  end
end

# import aliases
def import_aliases
  zshrc = File.join(ENV['HOME'], '.zshrc')

  unless File.read(zshrc).include?('/env/aliases')
    File.write(zshrc, "source $HOME/env/aliases\n", mode: 'a')
  end
end


# import .vimrc file
def import_vimrc

  vimrc = File.join(ENV['HOME'], '.vimrc');

  unless File.read(vimrc).include?('/env/vimrc')
    File.write(vimrc, "source $HOME/env/vimrc\n", mode: 'a')
  end
end


# plugin installer for vim
def installing_pathogen
  run('mkdir -p ~/.vim/autoload ~/.vim/bundle && \
      curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim')
end

# vundle is an another plugin manager
# inspired by ruby bundler

def installing_vundle
  run("git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim")
end


# import config files
import_aliases
import_vimrc

# instal pathogenfor plugins
installing_pathogen

# instsall plugins



