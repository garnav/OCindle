#!/bin/bash

# I wrote this line after looking at the following page on Stack Overflow:
# http://stackoverflow.com/questions/59895/getting-the-current-present-working-directory-of-a-bash-script-from-within-the-s
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# sudo apt-get remove tk8.4 tcl8.4
# sudo apt-get install tcl8.5 tk8.5
sudo apt-get install tk-dev

cd "$DIR"
mkdir wordnet
cd WordNet-3.0

./configure --prefix="$DIR/wordnet"

echo "export WNHOME=$DIR/wordnet" >> ~/.bash_profile
echo "export WNSEARCHDIR=$DIR/WordNet-3.0/dict" >> ~/.bash_profile
echo "export PATH=\$PATH:\${exec_prefix}/bin:$DIR/wordnet/bin" >> ~/.bash_profile
echo ". ~/.bash_profile" >> ~/.bashrc

make
make install

cd $DIR
rm wordnet.cmi
ocamlbuild 'wordnet.cma'

# opam install cohttp
opam install ANSITerminal

source ~/.bash_profile
