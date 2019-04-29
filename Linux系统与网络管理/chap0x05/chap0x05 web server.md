### 一、实验名称
高级Web服务器配置
### 二、实验要求
#### 基本要求

- 在一台主机（虚拟机）上同时配置Nginx和VeryNginx
- VeryNginx作为本次实验的Web App的反向代理服务器和WAF
- PHP-FPM进程的反向代理配置在nginx服务器上，VeryNginx服务器不直接配置Web站点服务
- 使用Wordpress搭建的站点对外提供访问的地址为： https://wp.sec.cuc.edu.cn 和 http://wp.sec.cuc.edu.cn
- 使用Damn Vulnerable Web Application (DVWA)搭建的站点对外提供访问的地址为： http://dvwa.sec.cuc.edu.cn

#### 安全加固要求

- 使用IP地址方式均无法访问上述任意站点，并向访客展示自定义的友好错误提示信息页面-1
- Damn Vulnerable Web Application (DVWA)只允许白名单上的访客来源IP，其他来源的IP访问均向访客展示自定义的友好错误提示信息页面-2
- 在不升级Wordpress版本的情况下，通过定制VeryNginx的访问控制策略规则，热修复WordPress < 4.7.1 - Username Enumeration
- 通过配置VeryNginx的Filter规则实现对Damn Vulnerable Web Application (DVWA)的SQL注入实验在低安全等级条件下进行防护

#### VeryNginx配置要求

- VeryNginx的Web管理页面仅允许白名单上的访客来源IP，其他来源的IP访问均向访客展示自定义的友好错误提示信息页面-3
- 通过定制VeryNginx的访问控制策略规则实现：
- 限制DVWA站点的单IP访问速率为每秒请求数 < 50
- 限制Wordpress站点的单IP访问速率为每秒请求数 < 20
- 超过访问频率限制的请求直接返回自定义错误提示信息页面-4
- 禁止curl访问

### 三、实验环境
- 实验环境服务器ip地址说明：由于实验时间跨度交到，分别多次进行，开启服务器顺序不同，所以ip地址设置并不唯一不变，但三个服务器均配置NAT与hostonly：196.168.56.*/24两块网卡
- 服务器×3
-  Ubuntu 16.04-1
- Ubuntu 16.04 desktop 64bit
- host only，NAT
- nginx/1.10.0
- verynginx
- ubuntu 16.04-2
- Ubuntu 16.04 desktop 64bit
- host only,NAT
- wordpress 4.
- nginx
- ubuntu 16.04-3
- Ubuntu 16.04 desktop 64bit
- host only,NAT
- dvwa 1.10
- nginx
- 客户端×2
- macOS Mojave 10.14.4
- ubuntu16.04-client（PD虚拟机内部）

### 四、实验过程
#### (一) 安装配置环境

#### 1. ubuntu 16.04-1 （nginx+verynginx）
-----------------------------
- 安装nginx`sudo apt-get install nginx`

- 安装build-essential、libpcre3-dev、libssl-dev/git
```bash
sudo apt-get install -y make build-essential libssl-dev libpcre3-dev
sudo apt-get install git

```
- 安装 VeryNginx
```bash

git clone https://github.com/alexazhou/VeryNginx.git
cd VeryNginx
sudo python install.py install
```

- 开启VeryNginx服务
```bash
#启动服务
sudo /opt/verynginx/openresty/nginx/sbin/nginx
#停止服务
sudo /opt/verynginx/openresty/nginx/sbin/nginx -s stop
#重启服务
sudo /opt/verynginx/openresty/nginx/sbin/nginx -s reload
```

- 浏览器地址栏输入`http://192.168.56.104`

![](/Linux系统与网络管理/chap0x05/images/1-1-1.png)

- 浏览器地址栏输入`https://192.168.56.104/verynginx/index.html`

![](/Linux系统与网络管理/chap0x05/images/1-1-2.png)

#### 2. ubuntu 16.04-3 (dvwa)
------------------------------
- 配置LEMP(LEMP=Linux+Nginx+Mysql+PHP)环境

- 安装Nginx
```bash
#安装Nginx
sudo apt-get update
sudo apt-get install nginx
#开启Nginx
sudo /etc/init.d/nginx start
```
![](/Linux系统与网络管理/chap0x05/images/2-1-1.png)

Nginx安装成功

- 安装Mysql安装成功
```bash
sudo apt-get install mysql-server
sudo service mysql start
mysql -u root -p
```

![](/Linux系统与网络管理/chap0x05/images/2-1-2.png)
Mysql安装成功

- PHP安装与配置
1. 安装PHP
```bash
#安装php
sudo apt-get install php-fpm php-mysql
#禁止PHP尝试执行它找不到所请求的PHP文件时可以找到的最接近的文件
sudo nano /etc/php/7.0/fpm/php.ini

```
![](/Linux系统与网络管理/chap0x05/images/2-2-1.png)

2. 配置Nginx以使用PHP处理器
```bash
sudo vim /etc/nginx/sites-available/default
#测试配置文件中的语法错误：
sudo nginx -t
#重新加载Nginx
sudo systemctl reload nginx
```
修改内容如下

![](/Linux系统与网络管理/chap0x05/images/2-2-2.png)

![](/Linux系统与网络管理/chap0x05/images/2-2-2-1.png)

3. 安装dvwa
- 到官网下载dvwa `DVWA-master.zip`压缩包，并解压到`var/www/html/`路径下，重命名`sudo mv DVWA-master dvwa`

![](/Linux系统与网络管理/chap0x05/images/2-3-1.png)

- 配置dvwa
```bash
#为DVWA创建用用户
GRANT ALL ON dvwa.* TO 'dvwauser'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
EXIT;

#配置文件config.inc.php
sudo vim /etc/php/7.0/fpm/php.ini
# 允许远程文件包含（RFI）
allow_url_include = On
#手动添加（如果PHP <= v5.4）允许SQL注入（SQLi）
magic_quotes_gpc = Off

sudo chown -R www-data:www-data /var/www/html/dvwa

#解决dvwa登录页面PHP module gd missing
apt install php-gd -y

# 重启php7.0-fpm,MySQL和nginx
sudo systemctl restart php7.0-fpm
sudo systemctl restart mysql
sudo systemctl restart nginx
```
- 浏览器访问`https://192.168.56.103/dvwa/setup.php`

![](/Linux系统与网络管理/chap0x05/images/QUE-2-8.png)

- 执行`sudo vim /etc/nginx/sites-available/default`修改nginx配置文件，为dvwa配置服务块
```bash
server {
listen 80 default_server; 
listen [::]:80 default_server; 
root /var/www/html/dvwa;

index index.php index.php index.nginx-debian.php;
server_name dvwa.sec.cuc.edu.cn;

location / {
try_files $uri $uri/ =404;
}

#配置php-fpm
location ~ \.php$ {
include snippets/fastcgi-php.conf;
fastcgi_pass unix:/run/php/php7.0-fpm.sock;
} 

location ~ /\.ht {
deny all;

}

}

# 重启MySQL和nginx
sudo systemctl restart mysql
sudo systemctl restart nginx
```
- 在本地macOS Mojave 和ubuntu16.04-3服务器添加hosts映射(该步实现对`dvwa.sec.cuc.edu.cn`的访问，并不是通过verynginx代理实现)

![](/Linux系统与网络管理/chap0x05/images/2-4-1.png)

- 宿主机macOS Mojave浏览器访问`http://dvwa.sec.cuc.edu.cn`，成功通过该url登陆dvwa

![](/Linux系统与网络管理/chap0x05/images/2-5-1.png)


#### 3. ubuntu 16.04-2 (wordpress)
-----------------------------------
1. 配置LEMP环境（与2步骤一致，不再赘述）
2. 为WordPress创建MySQL数据库和用户，要为WordPress创建一个可以控制的独立数据库和用户

3. 调整Nginx的配置以正确处理WordPress，通过创建要求精确匹配的位置开始块/favicon.ico和/robots.txt
```bash
sudo vim /etc/nginx/sites-available/default

```
4. 具体安装过程参考实验参考文献5（[Linux/Ubuntu16.04+Nginx+Mysql+PHP 搭建wordpress](https://blog.csdn.net/bonny722/article/details/82682696)）

5. 在服务器ubuntu16.04-2内部浏览，wordpress安装成功。

![](/Linux系统与网络管理/chap0x05/images/3-5-1.png)

6. [配置ssl](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-18-04)
```bash
#生成wordpress的私钥和证书 
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt

#notes
Common Name (e.g. server FQDN or YOUR name) []:192.168.56.101

#/etc/nginx/snippets/self-signed.conf
ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

#/etc/nginx/snippets/ssl-params.conf
ssl_protocols TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_dhparam /etc/nginx/dhparam.pem;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
ssl_ecdh_curve secp384r1; # Requires nginx >= 1.1.0
ssl_session_timeout  10m;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off; # Requires nginx >= 1.5.9
ssl_stapling on; # Requires nginx >= 1.3.7
ssl_stapling_verify on; # Requires nginx => 1.3.7
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
# Disable strict transport security for now. You can uncomment the following
# line if you understand the implications.
# add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
```

7. 执行`sudo vim /etc/nginx/sites-available/default`修改nginx配置文件，为wordpress配置服务块
```bash

#/etc/nginx/sites-available/default
server {
listen 80 ;  # 使用80端口监听
listen [::]:80 ; 
root /var/www/html/wordpress;
index index.php index.php index.nginx-debian.php; # php优先
server_name wp.sec.cuc.edu.cn;
location / {
#try_files $uri $uri/ =404;
#不是将404错误作为默认选项返回，而是index.php使用请求参数将控制传递给 文件
try_files $uri $uri/ /index.php$is_args$args;
}
location ~ \.php$ {
include snippets/fastcgi-php.conf;
fastcgi_pass unix:/run/php/php7.2-fpm.sock;
}
#以下为需要添加的location 
location = /favicon.ico {
log_not_found off; access_log off; 

} 
location = /robots.txt { 
log_not_found off; 
access_log off; allow all; 

} 
location ~*\.(css|gif|ico|jpeg|jpg|js|png)$ { 

expires max; log_not_found off; 

}
}
server {
listen 80;
listen [::]:80;

server_name wp.sec.cuc.edu.cn;

return 302 https://$server_name$request_uri;
}
server {
listen 443 ssl;
listen [::]:443 ssl;

include snippets/self-signed.conf;
include snippets/ssl-params.conf;

root /var/www/html/wordpress;
index index.php index.php index.nginx-debian.php;
server_name wp.sec.cuc.edu.cn;

location ~ \.php$ {
include snippets/fastcgi-php.conf;
fastcgi_pass unix:/run/php/php7.0-fpm.sock;
}

}

# 重启MySQL和nginx
sudo nginx -t
sudo systemctl restart mysql
sudo systemctl restart nginx

```

8. 在 macOS Mojave客户机本地和ubuntu16.04-2服务器添加hosts映射（仅仅测试服务器，后续实验会修改）
```bash
192.168.56.101 wp.sec.cuc.edu.cn
```

![](/Linux系统与网络管理/chap0x05/images/3-8-1.png)

9. 执行`sudo vim /var/www/html/wp-config.php`进行url relocate相关配置
```bash
# After the "define" statements (just before the comment line that says "That's all, stop editing!"), insert a new line, and type: 
define( 'RELOCATE', true );

#At the bottom add
if ( defined( 'RELOCATE' ) && RELOCATE ) { // Move flag is set
if ( isset( $_SERVER['PATH_INFO'] ) && ($_SERVER['PATH_INFO'] != $_SERVER['PHP_SELF']) )
$_SERVER['PHP_SELF'] = str_replace( $_SERVER['PATH_INFO'], "", $_SERVER['PHP_SELF'] );

$url = dirname( set_url_scheme( 'http://' .  $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'] ) );
if ( $url != get_option( 'siteurl' ) )
update_option( 'siteurl', $url );
} 
```

10. macOS Mojave客户机浏览器分别访问`http://wp.sec.cuc.edu.cn`与`https://wp.sec.cuc.edu.cn`（后续实验并未实现通过verynginx代理访问`https://wp.sec.cuc.edu.cn`），进行注册登录。
- `http://wp.sec.cuc.edu.cn`访问成功

![](/Linux系统与网络管理/chap0x05/images/3-9-1.png)

![](/Linux系统与网络管理/chap0x05/images/QUE-3-5.png)

- `https://wp.sec.cuc.edu.cn`访问成功

![](/Linux系统与网络管理/chap0x05/images/3-9-2.png)

#### 4. ubuntu 16.04-1 配置verynginx
---------------------------------------
1. 配置verynginx
- Matcher

![](/Linux系统与网络管理/chap0x05/images/basic_matcher.png)

- Up Stream,Proxy Pass

![](/Linux系统与网络管理/chap0x05/images/proxypass.png)

#### 实验结果实现
#### 基本要求

- [ ] 在一台主机（虚拟机）上同时配置Nginx和VeryNginx
- [ ] VeryNginx作为本次实验的Web App的反向代理服务器和WAF
- [x] ubuntu16.04-1等配置
- ubuntu16.04-1、ubuntu16.04-client、macOS-client`vim /etc/hosts`配置hosts

![](/Linux系统与网络管理/chap0x05/images/ubuntu1_hosts.png)
![](/Linux系统与网络管理/chap0x05/images/ubuntuc_hosts.png)
![](/Linux系统与网络管理/chap0x05/images/ubuntum_hosts.png)

- Matcher

![](/Linux系统与网络管理/chap0x05/images/basic_matcher.png)

- Up Stream,Proxy Pass

![](/Linux系统与网络管理/chap0x05/images/proxypass.png)

- 结果：Ubuntu16.04-1、macOS-client分别访问`http://dvwa.sec.cuc.edu.cn`,`http://wp.sec.cuc.edu.cn`

![](/Linux系统与网络管理/chap0x05/images/dvwa_proxy.png)
![](/Linux系统与网络管理/chap0x05/images/wp_proxy.png)
![](/Linux系统与网络管理/chap0x05/images/mdvwa_proxy.png)
![](/Linux系统与网络管理/chap0x05/images/mwp_proxy.png)

- [ ] PHP-FPM进程的反向代理配置在nginx服务器上，VeryNginx服务器不直接配置Web站点服务
- [x] wordpress和dvwa在nginx上的配置文件中写入: 
```bash
location ~ \.php$ {
include snippets/fastcgi-php.conf;
fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
}
```
![](/Linux系统与网络管理/chap0x05/images/phpfpmvernginx.png)

- [ ] 使用Wordpress搭建的站点对外提供访问的地址为：  http://wp.sec.cuc.edu.cn
- [x] 客户机macOS Mojave浏览器访问`http://wp.sec.cuc.edu.cn`成功通过该url登录

![](/Linux系统与网络管理/chap0x05/images/QUE-3-5.png)

- [ ] 使用Damn Vulnerable Web Application (DVWA)搭建的站点对外提供访问的地址为： http://dvwa.sec.cuc.edu.cn

- [x] 客户机macOS Mojave浏览器访问`http://dvwa.sec.cuc.edu.cn`，成功通过该url登录dvwa

![](/Linux系统与网络管理/chap0x05/images/2-5-1.png)


#### 安全加固要求

- [ ] 使用IP地址方式均无法访问上述任意站点，并向访客展示自定义的友好错误提示信息页面-1
- [x] ubuntu16.04-1配置
- Matcher

![](/Linux系统与网络管理/chap0x05/images/ip_disabled.png)

- Response

![](/Linux系统与网络管理/chap0x05/images/ip_response.png)

- Filter

![](/Linux系统与网络管理/chap0x05/images/ip_filter.png)

- 结果

![](/Linux系统与网络管理/chap0x05/images/ip_dissucceed.png)

- [ ] Damn Vulnerable Web Application (DVWA)只允许白名单上的访客来源IP，其他来源的IP访问均向访客展示自定义的友好错误提示信息页面-2
- [x] ubuntu16.04-1配置:将ubuntu16.04-client ip：`192.168.56.102`列入白名单
- Matcher

![](/Linux系统与网络管理/chap0x05/images/dvwa_wallowed.png)

- Response

![](/Linux系统与网络管理/chap0x05/images/dvwa_wresponse.png)

- Filter

![](/Linux系统与网络管理/chap0x05/images/dvwa_wfilter.png)

- 结果：macOS(192.168.56.101)与ubuntu16.04-client(192.168.56.102/10)分别访问`dvwa.sec.cuc.edu.cn`

![](/Linux系统与网络管理/chap0x05/images/dvwa_wsucceed.png)
![](/Linux系统与网络管理/chap0x05/images/dvwa_mwsucceed.png)
![](/Linux系统与网络管理/chap0x05/images/dvwa_wsucceed1.png)


- [ ] 在不升级Wordpress版本的情况下，通过定制VeryNginx的访问控制策略规则，热修复WordPress < 4.7.1 - Username Enumeration
- [x] ubuntu16.04-1配置[`访问/wp-json/wp/v2/users/可以获取wordpress用户信息的json数据，禁止访问·`wp.sec.cuc.edu.cn`站点的/wp-json/wp/v2/users/路径`](https://github.com/CUCCS/linux/blob/master/2017-1/zjy/exp5/exp5%E5%AE%9E%E9%AA%8C%E6%8A%A5%E5%91%8A.md)

- Matcher

![](/Linux系统与网络管理/chap0x05/images/wp_uedisabled.png)

- Filter

![](/Linux系统与网络管理/chap0x05/images/wp_uefilter.png)

- 结果：ubuntu16.04-client访问`wp.sec.cuc.edu.cn/wp-json/wp/v2/users`
- 未设置过滤规则之前

![](/Linux系统与网络管理/chap0x05/images/wp_uefailed.png)     

- 设置过滤规则后

![](/Linux系统与网络管理/chap0x05/images/wp_uesucceed.png)


- [ ] 通过配置VeryNginx的Filter规则实现对Damn Vulnerable Web Application (DVWA)的SQL注入实验在低安全等级条件下进行防护
- [x] ubuntu16.04-1、ubuntu16.04-3配置
- ubuntu16.04-3将dvwa设置为低安全防护等级

![](/Linux系统与网络管理/chap0x05/images/dvwa_setlowsecurity.png)

-  SQL 注入

![](/Linux系统与网络管理/chap0x05/images/dvwa_setlowsecuritysql.png)  

- ubuntu16.04-3 Matcher

![](/Linux系统与网络管理/chap0x05/images/dvwa_sqldisabled.png)

- ubuntu16.04-3 Response

![](/Linux系统与网络管理/chap0x05/images/dvwa_sqldissponse.png)

- ubuntu16.04-3 Filter

![](/Linux系统与网络管理/chap0x05/images/dvwa_sqldisfilter.png)

- 结果:ubuntu16.04-3 dvwa页面再次尝试sql注入

![](/Linux系统与网络管理/chap0x05/images/dvwa_sqldisucceed.png)

#### VeryNginx配置要求

- [ ] VeryNginx的Web管理页面仅允许白名单上的访客来源IP，其他来源的IP访问均向访客展示自定义的友好错误提示信息页面-3
- [ ] ubuntu16.04-1配置
- Matcher

![](/Linux系统与网络管理/chap0x05/images/verynginxwhitematcher.png)

- Response

![](/Linux系统与网络管理/chap0x05/images/verynginxwhitere.png)

- Filter

![](/Linux系统与网络管理/chap0x05/images/verynginxwhitefilter.png)


- 未位于白名单的ip地址为`192.168.56.104`的ubuntu16.04-client和macos不可以访问

![](/Linux系统与网络管理/chap0x05/images/verynginxwhite.png)

![](/Linux系统与网络管理/chap0x05/images/verynginxwhite1.png)

- 未位于白名单的ubuntu16.04-1`192.168.56.104`可以访问

![](/Linux系统与网络管理/chap0x05/images/verynginxnwhite.png)

- [ ] 通过定制VeryNginx的访问控制策略规则实现：
- [ ] 限制DVWA站点的单IP访问速率为每秒请求数 < 50
- [ ] 限制Wordpress站点的单IP访问速率为每秒请求数 < 20
- [ ] 超过访问频率限制的请求直接返回自定义错误提示信息页面-4
- [x] ubuntu16.04-1配置
- Frequency Limit

![](/Linux系统与网络管理/chap0x05/images/frequencylimit.png)

- Response

![](/Linux系统与网络管理/chap0x05/images/frequencylimitRE.png)

- macOS Mojave编写脚本访问`http://dvwa.sec.cuc.edu.cn`
```bash
#!/bin/bash
# dvwa_frequencytest.sh
count=0
while [[ $count -lt 53 ]]
do
echo "Frequency : $count"
curl -I dvwa.sec.cuc.edu.cn/verynginx/index.html
count=$[ $count + 1 ]
done
```

![](/Linux系统与网络管理/chap0x05/images/dvwale50succeed.png)

- macOS Mojave编写脚本访问`http://wp.sec.cuc.edu.cn`
```bash
#!/bin/bash
# wordpress_frequencytest.sh
count=0
while [ $count -lt 23 ]
do
echo "Frequency : $count"
curl -I wp.sec.cuc.edu.cn/verynginx/index.html
count=$[ $count + 1 ]
done
```

![](/Linux系统与网络管理/chap0x05/images/wple20succeed.png)

- [ ] 禁止curl访问

- [x] ubuntu16.04-1配置
- Matcher 

![](/Linux系统与网络管理/chap0x05/images/curldisabledm.png)

- Response

![](/Linux系统与网络管理/chap0x05/images/curldisabled.png)

- Filter

![](/Linux系统与网络管理/chap0x05/images/curldisabledf.png)

- 结果:ubuntu16.04-client执行`curl -v http://dvwa.sec.cuc.edu.cn`

![](/Linux系统与网络管理/chap0x05/images/disable_curlsucceed.png)

### 六、实验问题
- [ ] 安装完VeryNginx后无法通过浏览器输入`http://{{your_docker_machine_address}}/verynginx/index.html`打开web面板,结合安装过程中虽然显示了`All work finished successfully，enjoyit`，但是仔细查看安装结果信息存在`openresty not found，so not copy nginx.conf`

![](/Linux系统与网络管理/chap0x05/images/QUE-1-1.png)
![](/Linux系统与网络管理/chap0x05/images/QUE-1-2.png)

- [x] VeryNginx的安装脚本install.py提供自动安装openresty，但并没有安装上安装openresty,单独安装openresty
```bash
cd VeryNginx-0.3.3/
sudo python install.py install openresty
```
![](/Linux系统与网络管理/chap0x05/images/1-1-1.png)

- 启动VeryNginx遇到`Permission denied`的问题

![](/Linux系统与网络管理/chap0x05/images/QUE-2-1.png)

- [x] 添加nginx用户，修改命令语句

```bash
#添加nginx用户
sudo adduser nginx
#启动服务
sudo /opt/verynginx/openresty/nginx/sbin/nginx
```
![](/Linux系统与网络管理/chap0x05/images/1-1-2.png)
- [ ] 将dvwa移动到`/var/www/html`路径下，浏览器访问`https://192.168.56.102/DVWA-master/` 显示 `403 Forbidden

![](/Linux系统与网络管理/chap0x05/images/QUE-2-2.png)
`This page isn't working`
![](/Linux系统与网络管理/chap0x05/images/QUE-2-4.png)



![](/Linux系统与网络管理/chap0x05/images/QUE-2-3.png)

- [x] 修改`/var/www/html/DVWA-master`权限，修改`/etc/php/7.0/fpm/php.ini`把dvwa需要的allow_url_include改成On，查阅资料尝试很多方法但是还是未能解决问题，最终更换新的Ubuntu 16.04虚拟机重新配置环境，dvwa安装配置成功。

![](/Linux系统与网络管理/chap0x05/images/QUE-2-5.png)
![](/Linux系统与网络管理/chap0x05/images/QUE-2-8.png)

- [ ] 浏览器浏览`http://192.168.56.103/DVWA-master`错误提示信息如下

![](/Linux系统与网络管理/chap0x05/images/QUE-2-6.png)

- [x] 在`/var/www/html/DVWA-master/config`路径下执行`sudo cp config.inc.php.dist config.inc.php`问题得以解决

![](/Linux系统与网络管理/chap0x05/images/QUE-2-7.png)
![](/Linux系统与网络管理/chap0x05/images/QUE-2-8.png)
- [ ] 在实验过程实验三部分，对于wordpress用户在macOS客户机点击「登录」时，浏览器地址栏url会重定向到`196.168.56.101/wp-login.php`,而不是`wp.sec.cuc.cn/wp-login.php`

![](/Linux系统与网络管理/chap0x05/images/QUE-3-1.png)
![](/Linux系统与网络管理/chap0x05/images/QUE-3-2.png)

- [x] [配置 `/var/www/html/wp--config.php`](https://codex.wordpress.org/Changing_The_Site_URL)
```bash
# After the "define" statements (just before the comment line that says "That's all, stop editing!"), insert a new line, and type: 
define( 'RELOCATE', true );

#At the bottom add
if ( defined( 'RELOCATE' ) && RELOCATE ) { // Move flag is set
if ( isset( $_SERVER['PATH_INFO'] ) && ($_SERVER['PATH_INFO'] != $_SERVER['PHP_SELF']) )
$_SERVER['PHP_SELF'] = str_replace( $_SERVER['PATH_INFO'], "", $_SERVER['PHP_SELF'] );

$url = dirname( set_url_scheme( 'http://' .  $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'] ) );
if ( $url != get_option( 'siteurl' ) )
update_option( 'siteurl', $url );
} 
```
![](/Linux系统与网络管理/chap0x05/images/QUE-3-4.png)

- 实验结果展示说明该问题成功解决
- [ ] 在WordPress相关实验中配置服务块使其可以通过`https://wp.sec.cuc.edu.cn`访问，修改default的配置文件，`systemctl restart nginx`&&`nginx -t`并查看详细信息。

![](/Linux系统与网络管理/chap0x05/images/QUE-4-1.png)
![](/Linux系统与网络管理/chap0x05/images/QUE-4-2.png)
- [ ] 初始通过wget命令下载verynginx，不存在对response的配置
```bash
#初始使用问题命令
wget https://github.com/alexazhou/VeryNginx/archive/v0.3.3.zip
unzip v0.3.3.zip
cd VeryNginx-0.3.3/
sudo python install.py install openresty
sudo python install.py install verynginx
cd ../
```

![](/Linux系统与网络管理/chap0x05/images/QUE-5-1.png)

- [x] 尝试重新下载verynginx与其他方法均未能解决，应用`git`命令解决问题（实验任务实现已证问题解决）
- [ ] verynginx配置页面出现`Ajax request failed`

![](/Linux系统与网络管理/chap0x05/images/QUE-6-1.png)

- [x] 在实现安全加固任务，禁止任意站点通过ip被访问因为Matcher设置了如下，那verynginx本身的通过ip访问也会被禁止掉，为了避免对自身配置页面也被禁止掉，新加配置

![](/Linux系统与网络管理/chap0x05/images/QUE-6-2.png)

- 访问失败

![](/Linux系统与网络管理/chap0x05/images/QUE-6-3.png)

- [ ] 在安装dvwa时即使先进行了数据库的配置，但是在ubuntu16.04-3上依据无法连接数据库。

![](/Linux系统与网络管理/chap0x05/images/QUE-7-2.png)

- [x] 尝试多种修改方法，最终参考，重新启动数据库删除已经建立的数据库，并通过root用户登录数据库，然后进行相关配置，最终解决问题。

![](/Linux系统与网络管理/chap0x05/images/QUE-7-1.png)

- [x] 选择用三个虚拟机实现三个服务器，个人认为这样更能模拟真实场景。综合整个实验过程，遇到很多问题，完成整个实验花费时间较长，搜索针对性学习文章、处理选择信息的能力、解决问题能力均有待进一步提高。

### 七、实验参考
- [VeryNginx](https://github.com/alexazhou/VeryNginx/blob/master/readme_zh.md)
- [开始使用 VeryNginx](http://www.udpwork.com/item/15995.html)
- [How To Install Linux, Nginx, MySQL, PHP (LEMP stack) in Ubuntu 16.04 ](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04)
- [How To Install WordPress with LEMP on Ubuntu 16.04 ](https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-lemp-on-ubuntu-16-04)
- [How to Install and Configure DVWA Lab on Ubuntu 18.04 server](https://kifarunix.com/how-to-setup-damn-vulnerable-web-app-lab-on-ubuntu-18-04-server/)
- [Linux/Ubuntu16.04+Nginx+Mysql+PHP 搭建wordpress](https://blog.csdn.net/bonny722/article/details/82682696)
- [How To Create a Self-Signed SSL Certificate for Nginx in Ubuntu 16.04 ](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04)
