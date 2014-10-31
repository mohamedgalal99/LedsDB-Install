#!/bin/bash


#Install required packages#

apt-get install make gcc git unzip mercurial git -y
apt-get install g++ -y
apt-get install tmux -y
apt-get install autoconf -y
apt-get install pkg-config -y
apt-get install zlib -y
apt-get install libgflags-dev -y
apt-get install zlib1g-dev -y
apt-get install libbz2-dev -y
apt-get install libsnappy-dev -y
apt-get install libreadline-dev -y
aptitude install libtool -y


#Install Go#

if [ -e '/usr/local/go' ]; then
	echo 'GO allready found in /usr/local/go'
else
	wget https://storage.googleapis.com/golang/go1.3.3.linux-amd64.tar.gz
	tar xzvf go1.3.3.linux-amd64.tar.gz -C /usr/local/
	rm go1.3.3.linux-amd64.tar.gz
	export GOROOT=/usr/local/go
	export PATH=$PATH:$GOROOT/bin
	mkdir /opt/test
	export GOPATH=/opt/test
fi

#Install godep#

cd $GOPATH
git clone https://github.com/tools/godep.git
go get github.com/tools/godep
env | grep -w "PATH\=" | grep -wq "$GOPATH\/bin" || export PATH=$PATH:$GOPATH/bin


#Insatall rocksdb#

cd $GOPATH
git clone https://github.com/facebook/rocksdb.git
cd rocksdb
make shared_lib
mkdir -p /usr/local/rocksdb/lib
cp librocksdb.so /usr/local/rocksdb/lib/
cp -r include/ /usr/local/rocksdb/
ln -s /usr/local/rocksdb/lib/librocksdb.so /usr/lib/librocksdb.so

#Install lua

cd /usr/local/
git clone https://github.com/LuaDist/lua.git
cd /usr/local/lua/src
cp luaconf.h.orig luaconf.h
make linux
make test

#Install Ledisdb

cd $GOPATH
git clone https://github.com/siddontang/ledisdb.git src/github.com/siddontang/ledisdb
export GOBIN=$GOPATH/bin
cd $GOPATH/src/github.com/siddontang/ledisdb/
# Install snappy and leveldb
sh tools/build_leveldb.sh
echo '/usr/local/snappy/lib' > /etc/ld.so.conf.d/snappy.conf
echo '/usr/local/leveldb/lib' > /etc/ld.so.conf.d/leveldb.conf
./bootstrap.sh 
source dev.sh
make
make test
cp etc/ledis.conf /etc

# Put in bash.bashrc

echo "
if [[ -z \"\$GOROOT\" ]]; then
    export GOROOT=/usr/local/go
    export PATH=\$PATH:\$GOROOT/bin
    env | grep -wq 'GOPATH\=' || export GOPATH=/opt/test
    env | grep -w \"PATH\=\" | grep -wq \"\$GOPATH\/bin\" || export PATH=\$PATH:\$GOPATH/bin
    export GOBIN=\$GOPATH/bin
fi

" >> /etc/bash.bashrc
source /etc/bash.bashrc

echo 'INSTALLION FINISHED :D :D :D'
