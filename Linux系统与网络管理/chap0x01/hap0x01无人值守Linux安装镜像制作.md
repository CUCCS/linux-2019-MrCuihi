### 一、实验名称
无人值守Linux安装镜像制作
### 二、实验问题
- 如何配置无人值守安装iso并在Virtualbox中完成自动化安装？
- Virtualbox安装完Ubuntu之后新添加的网卡实现系统开机自动启用和自动获取IP？
- 如何使用sftp（在22端口传输）在虚拟机和宿主机之间传输文件？
### 三、实验环境
- virtualbox
- Ubuntu 18.04  Server 64bit
- 网卡选择（双网卡）
  - 网卡一：NAT（网络地址转换）
  - 网卡二：Host-only
### 四、实验过程
1.查看网卡信息
```bash
ifconfig -a
```
![](/Linux系统与网络管理/chap0x01/images/4-1-1.png)

2.开启host only网卡DHCP
```bash
sudo dhclient enp0s8
```

![](/Linux系统与网络管理/chap0x01/images/4-2-1.png)

3.开启Ubuntu18.04server ssh 服务
```bash
sudo apt-get install openssh-server
sudo service ssh open
```

4.在mac os的宿主机利用ssh连接目标机Ubuntu 18.04 server ，并将宿主机中ubuntu-18.04.1-server-amd64.iso镜像远程传送到目标服务器上
```bash
ssh cuc@192.168.56.101
scp /Users/cclin/Desktop/ubuntu-18.04.1-server-amd64.iso cuc@192.68.56.101:/home/cuc/mountdir
```
![](/Linux系统与网络管理/chap0x01/images/4-4.2-1.png)

在Ubuntu 18.04 server中查看mountdir路径下存在通过远程传输的镜像，镜像远程传输成功

![](/Linux系统与网络管理/chap0x01/images/4-4.2-2.png)

5.在当前目录路径即mountdir下创建loopdir路径用于挂载镜像，把ubuntu-18.04.1-server-amd64.iso光盘镜像挂载到目录mountdir
```bash
mkdir loopdir
sudo mount -o loop ubuntu-18.04.1-server-amd64.iso mountdir
```

![](/Linux系统与网络管理/chap0x01/images/4-5-1.png)

6.创建一个工作目录用于克隆光盘内容，并将光盘内容同步到新创建的工作目录 `cd`，同步成功后卸载该镜像
```bash
mkdir cd
#同步loopdir路径下镜像到路径cd
sudo rsync -av loopdir/ cd
```
![](/Linux系统与网络管理/chap0x01/images/4-6-1.png)

```bash
#卸载loopdir路径下镜像
sudo umount loopdir
```
![](/Linux系统与网络管理/chap0x01/images/4-6-2.png)

7.进入先前创建的目标工作目录cd,编辑Ubuntu安装引导界面增加一个新菜单项入口
```bash
#编辑Ubuntu安装引导界面
sudo vim isolinux/txt.cfg
```
![](/Linux系统与网络管理/chap0x01/images/4-7-1.png)

8.在isolinux/txt.cfg编辑添加以下内容
```bash
label autointall
  menu label ^Auto Install Ubuntu Server
  kernel /install/vmlinuz
  append file=/cdrom/preseed/ubuntu-server-autoinstall.seed debian-installer/local=en_US console-setup/layoutcode=us keyboard-configuration/layoutcode=us console-setup/ask_detect=false localechooser/translation/warn-light=true localechooser/translation/warn-server=true initrd=/install/initrd.gz root=/dev/ram rw quiet ---

```

![](/Linux系统与网络管理/chap0x01/images/4-8-1.png)

输入`exit` `:` `wq!`强制保存后退出

9.提前阅读并编辑定制Ubuntu官方提供的示例preseed.cfg,并重命名为ubuntu-server-autoinstall.seed，用ssh传输到目标服务器并包存到ubuntu服务器刚才创建的工作目录~/mountdir/cd/preseed/ubuntu-server-autoinstall.seed
```bash
scp /Users/cclin/Desktop/unbuntu-server-autoinstall.seed cuc@192.168.56.101:/home/cuc/mountdir/cd
```
![](/Linux系统与网络管理/chap0x01/images/4-9-1.png)
![](/Linux系统与网络管理/chap0x01/images/4-9-2.png)

传输成功

10.修改isolinux/isolinux.cfg，增加内容`timeout 10`，使其镜像在安装时自动进入安装界面

![](/Linux系统与网络管理/chap0x01/images/4-10-1.png)

11.重新生成md5sum.txt
```bash
sudo chmod 777 md5sum.txt
sudo find . -type f -print0 | xargs -0 md5sum > md5sum.txt
```

![](/Linux系统与网络管理/chap0x01/images/4-11-1.png)

12.建立shell镜像，添加以下内容，把脚本保存成bash文件`save.sh`
```bash
#新建save.sh
touch save.sh
vi save.sh
```
![](/Linux系统与网络管理/chap0x01/images/4-12-1.png)

13.封闭改动后的目录到.iso，并执行save.sh脚本，完成镜像刻录
```bash
#安装mkisofs光盘镜像工具
sudo apt-get insatll mkisofs
#执行shell脚本
sudo bash save.sh
```
![](/Linux系统与网络管理/chap0x01/images/4-13-1.png)

成功生成custom,iso

![](/Linux系统与网络管理/chap0x01/images/4-13-2.png)

14.在宿主机上利用ssh下载Ubuntu服务器上生成的custom.iso
```bash
scp cuc@192.168.56.101:/home/cuc/mountdir/cd/custom.iso /Users/cclin/Desktop
```
![](/Linux系统与网络管理/chap0x01/images/4-14-1.png)

15.新建虚拟机，使用无人值守iso安装虚拟机

![](/Linux系统与网络管理/chap0x01/images/4-15-1.png)

### 五、实验结果
- 无人值守安装
- ![](/Linux系统与网络管理/chap0x01/images/4-14-1.png)

### 六、思考问题
- 官方示例文件preseed.cfg与ubuntu-server-autoinstall.seed对比
- [ ] 做了哪些修改？
- [ ] 这些修改的作用是什么？
- 1.locales语言设置修改
  - 支持多种语言环境：美国和中国
  
  ![](/Linux系统与网络管理/chap0x01/images/6-1-1.png)

  - 不支持安装语言：
  
![](/Linux系统与网络管理/chap0x01/images/6-1-2.png)

- 2.网络设置修改
   - 网络连接超时设置为5s
   - dhcp超时时间为5s
   - 关闭自动设置网络
   
   ![](/Linux系统与网络管理/chap0x01/images/6-2-1.png)

   - 配置静态ip，设置ip地址、网络掩码、网关、名字服务器并确认是静态网络，关闭动态配置。
   - 设置域名服务器主机名与域名
   - 设置主机名
   
   ![](/Linux系统与网络管理/chap0x01/images/6-2-2.png)

- 3.账户设置修改
   - 配置账户的用户名和密码
   
   ![](/Linux系统与网络管理/chap0x01/images/6-3-1.png)

- 4.时钟和时区设置修改
   - 设置时区为亚洲上海
   - 关闭自动设置时间
   
   ![](/Linux系统与网络管理/chap0x01/images/6-4-1.png)

- 5.分区设置修改
   - 自动选择使用全部物理空间
   
    ![](/Linux系统与网络管理/chap0x01/images/6-5-1.png)

   - 允许LVM使用全部空间
   - 设置/home, /var, /tmp不同分区
   
   ![](/Linux系统与网络管理/chap0x01/images/6-5-2.png)

- 6.Apt启动设置修改
   - 禁止使用网络镜像资源
   
    ![](/Linux系统与网络管理/chap0x01/images/6-6-1.png)

- 7.安装包设置修改
   - 安装server包
   - 安装 openssh-server包，禁止自动更新
   - 设置自动安装安全更新
    
   ![](/Linux系统与网络管理/chap0x01/images/6-7-1.png)

- [ ] 用什么「工具」能提高「差异」比对的效率？
- [x] 可以选择如Subline Text等专业文档工具帮助对比差异，提高效率

### 七、实验问题
- [ ] 初始在mac os系统宿主机上使用putty远程传输到Ubuntu目标服务器文件，怀疑可能是putty程序安装的路径与要传输文件的路问题。

![](/Linux系统与网络管理/chap0x01/images/QUE-1-1.png)

- [x] 多次尝试均失败，改用ssh进行目标文件从宿主机到服务器的远程传输

![](/Linux系统与网络管理/chap0x01/images/4-4.2-1.png)

- [ ] 修改isolinux/txt.cfg后退出未保存修改内容
- [x] 该文件所在文件夹cd不具有write权限，为cd赋予写权限
```bash
#给拥有者赋予读写执行写权限
chmod u=rwx cd
```
- [ ] 在实验过程的步骤9利用ssh传输unbuntu-server-autoinstall时失败

![](/Linux系统与网络管理/chap0x01/images/QUE-4-1.png)

- [x] 在ubuntu服务器修改preseed文件权限
```bash
#所有用户均具有读写执行权限
chrom a=rwx preceed
```
![](/Linux系统与网络管理/chap0x01/images/4-9-1.png)
![](/Linux系统与网络管理/chap0x01/images/4-9-2.png)

- 传输成功

- [ ] 在实验过程步骤13，执行save.sh脚本出现问题
 
![](/Linux系统与网络管理/chap0x01/images/QUE-5-1.png)

- [x] 根据提示信息，经过检查后是在save.h设置存在问题修改后解决，save.sh脚本成功运行

![](/Linux系统与网络管理/chap0x01/images/QUE-6-1.png)