#!/bin/sh
mkdir ./server
cd ./server
CPUNO=`cat /proc/cpuinfo|grep 'processor'|wc -l`
MEM=$(cat /proc/meminfo |grep 'MemTotal' |awk -F : '{print $2}' |sed 's/^[ \t]*//g'|sed 's/ kB$//g') 
PHP_FPM_NO=$[$MEM / 30000]

groupadd www
useradd -g www -d /home/www -m www
# 下载源文件
yum install -y gcc gcc-c++ make cmake bison autoconf wget lrzsz 
wget http://cn2.php.net/distributions/php-7.0.17.tar.gz
wget http://tengine.taobao.org/download/tengine-2.2.0.tar.gz
# 安装必要文件

yum install -y libtool libtool-ltdl-devel  
yum install -y freetype-devel libjpeg.x86_64 libjpeg-devel libpng-devel gd-devel 
yum install -y python-devel  patch  sudo  
yum install -y openssl* openssl openssl-devel ncurses-devel 
yum install -y bzip* bzip2 unzip zlib-devel 
yum install -y libevent* 
yum install -y libxml* libxml2-devel 
yum install -y libcurl* curl-devel  
yum install -y readline-devel 
yum install -y libmcrypt libmcrypt-devel mcrypt mhash
yum -y install automake
yum -y install zlib zlib-devel pcre-devel
#解压文件
tar -zxvf php-7.0.17.tar.gz
tar -zxvf tengine-2.2.0.tar.gz
cd php-7.0.17
./configure --prefix=/usr/local/php7 --with-config-file-path=/usr/local/php7/etc --with-config-file-scan-dir=/usr/local/php7/etc/php.d --with-mcrypt=/usr/include --enable-mysqlnd --with-mysqli --with-pdo-mysql --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-gd --with-iconv --with-zlib --enable-xml --enable-shmop --enable-sysvsem --enable-inline-optimization --enable-mbregex --enable-mbstring --enable-ftp --enable-gd-native-ttf --with-openssl --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --enable-session --with-curl --with-jpeg-dir --with-freetype-dir --enable-opcache 
make -j$CUPNO
make install
cd ../tengine-2.2.0
mkdir /var/tmp/nginx
./configure --prefix=/usr/local/nginx --sbin-path=/usr/sbin/nginx --conf-path=/usr/local/nginx/config/nginx.conf --error-log-path=/var/log/nginx/error.log --pid-path=/var/run/nginx/nginx.pid --user=www --group=www --with-http_ssl_module --with-http_flv_module --with-http_gzip_static_module --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/tmp/nginx/client --http-proxy-temp-path=/var/tmp/nginx/proxy --http-fastcgi-temp-path=/var/tmp/nginx/fcgi --with-http_stub_status_module
make -j$CPUNO
make install
cd ../..
cat nginx.conf|sed '2c worker_processes '"$CPUNO;" > nginx.conf.tmp
cp nginx.conf.tmp /usr/local/nginx/config/nginx.conf
rm -f nginx.conf.tmp
mkdir -p /usr/local/nginx/config/vhost
mkdir -p /usr/local/nginx/logs
cp www.conf /usr/local/nginx/config/vhost/www.conf
cp php.ini /usr/local/php7/etc/php.ini
cp php-fpm.conf /usr/local/php7/etc/php-fpm.conf
cat php-www.conf | sed '12c pm.max_children = '"$PHP_FPM_NO" > php-www.conf.tmp
cp php-www.conf.tmp /usr/local/php7/etc/php-fpm.d/www.conf
rm -f php-www.conf.tmp

cp php-fpm7 /etc/init.d/php-fpm7
cp nginx /etc/init.d/nginx
chmod 755 /etc/init.d/php-fpm7
chmod 755 /etc/init.d/nginx
chkconfig php-fpm7 on
chkconfig nginx on
service php-fpm7 start
service nginx start
echo '安装完成'
echo "php 进程数 $PHP_FPM_NO"
