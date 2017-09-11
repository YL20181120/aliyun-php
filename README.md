阿里云ECS PHP环境安装脚本
---

* PHP版本 7.0.17
* tengine 版本 2.2.0

### 启动方式

`service php-fpm7 start|restart|stop`

`service nginx congfigtest|start|restart|stop|reload`

### 安装
`wget https://github.com/Jasmine2/aliyun-php/archive/v0.1.tar.gz`

`tar -zxvf aliyun-php-0.1.tar.gz`

`cd aliyun-php-0.1`

`./alyun.sh`
