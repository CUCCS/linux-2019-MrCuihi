### 一、实验内容
- [Systemd 入门教程：命令篇 by 阮一峰的网络日志](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)
- [Systemd 入门教程：实战篇 by 阮一峰的网络日志](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)
### 二、实验环境
Ubuntu 18.04 Server 64bit
### 三、实验过程
#### 命令篇
- [三、系统管理](https://asciinema.org/a/4XM43up6tJCj0HoKIFD11NFoQ)

[![asciicast](https://asciinema.org/a/4XM43up6tJCj0HoKIFD11NFoQ.svg)](https://asciinema.org/a/4XM43up6tJCj0HoKIFD11NFoQ)

- [四、Unit](https://asciinema.org/a/m0OCOgI3Jkp8reHZJxlkF05lM)

[![asciicast](https://asciinema.org/a/m0OCOgI3Jkp8reHZJxlkF05lM.svg)](https://asciinema.org/a/m0OCOgI3Jkp8reHZJxlkF05lM)

- [五、Unit配置文件](https://asciinema.org/a/gpGDTfDBs3kJeWqCtf8u4Iqm9)

[![asciicast](https://asciinema.org/a/gpGDTfDBs3kJeWqCtf8u4Iqm9.svg)](https://asciinema.org/a/gpGDTfDBs3kJeWqCtf8u4Iqm9)

- [六、Target](https://asciinema.org/a/jG8xXRQ9aODOEzEGud2gO0km1)

[![asciicast](https://asciinema.org/a/jG8xXRQ9aODOEzEGud2gO0km1.svg)](https://asciinema.org/a/jG8xXRQ9aODOEzEGud2gO0km1)

- [七、日志管理](https://asciinema.org/a/15ZMsMlQkA11qwb9aWb3u1Ram)

[![asciicast](https://asciinema.org/a/15ZMsMlQkA11qwb9aWb3u1Ram.svg)](https://asciinema.org/a/15ZMsMlQkA11qwb9aWb3u1Ram)

#### 实战篇
- [实战训练](https://asciinema.org/a/WntemW6D2y3i4OpH7uZBY322g)

[![asciicast](https://asciinema.org/a/WntemW6D2y3i4OpH7uZBY322g.svg)](https://asciinema.org/a/WntemW6D2y3i4OpH7uZBY322g)

### 四、实验自查清单
- [ ] 如何添加一个用户并使其具备sudo执行程序的权限？
- [x] 命令如下
```bash
# 添加一个普通用户commuser
sudo adduser commuser
# 切换到用户commuser
su commuser
# 执行 sudo，不有sudo执行程序权限
sudo su -
# 切回到cuc
su cuc
# 将用户commuser加入sudo组内
sudo adduser commuser sudo
# 切换到用户commuser
su commonuser
# 执行 sudo，具有sudo执行程序权限
sudo su -
```
[![asciicast](https://asciinema.org/a/fb8HLBEcIRwj2gsBL2wKf7KzV.svg)](https://asciinema.org/a/fb8HLBEcIRwj2gsBL2wKf7KzV)

- [ ] 如何将一个用户(username)添加到一个用户组(usergroup)？ 
- [x] 命令如下
```bash
# 创建新用户组grouptest
sudo groupadd grouptest
# 创建用户 usert 并将其加入到 groupt 用户组：
sudo adduser usert grouptest
# 可以查看用户usert的属性，使用 id 命令：
id usert
```
[![asciicast](https://asciinema.org/a/fCm9rj42IGHIORnfc32BSDI7C.svg)](https://asciinema.org/a/fCm9rj42IGHIORnfc32BSDI7C)

- [ ] 如何查看当前系统的分区表和文件系统详细信息？
- [x] 命令如下
```bash
#查看当前系统分区表
sudo fdisk -l
sudo sfdisk -l
cfdisk
# 查看文件系统详细信息
df -a
```
[![asciicast](https://asciinema.org/a/mFWlXSmXsyLXAUjP3ggaYSqcB.svg)](https://asciinema.org/a/mFWlXSmXsyLXAUjP3ggaYSqcB)

- [ ] 如何实现开机自动挂载Virtualbox的共享目录分区？
- [x] virtualbox面板中选定要操作的虚拟机-->设置-->共享文件夹-->添加共享文件夹-->勾选‘固定分配’。

![](/Linux系统与网络管理/chap0x03/images/4-4-1.png)

```
# 新建挂载目录
mkdir ~/sharefolder
# 挂载共享文件夹ShareFolder到新建挂载目录
sudo mount -t vboxsf ShareFolder ~/sharefolder
# 打开fstab文件修改配置文件
sudo vi /etc/fstab
# 添加配置信息
vbshare /home/cuc/sharefolder vboxsf defaults 0 0
# 重启
sudo reboot
```
![](/Linux系统与网络管理/chap0x03/images/4-4-2.png)

- [ ] 基于LVM（逻辑分卷管理）的分区如何实现动态扩容和缩减容量？
- [x] 命令如下
```bash
# 查看逻辑卷信息
sudo lvdisplay
# 动态扩容3MB 
sudo lvextend --size +3MB /dev/bogon-vg/root
# 缩减容量3MB 
sudo lvreduce --size -3MB /dev/bogon-vg/root
# 更改大小3MB 
sudo lvresize --size +3MB /dev/bogon-vg/root
```
[![asciicast](https://asciinema.org/a/cJSSacAOkEfQFfc9wb3gnCtfq.svg)](https://asciinema.org/a/cJSSacAOkEfQFfc9wb3gnCtfq)

- [ ] 如何通过systemd设置实现在网络连通时运行一个指定脚本，在网络断开时运行另一个脚本？
- [x] 修改NetworkManager.service配置文件的Service区块
```bash
# 设置网络联通时运行脚本scripta（假设脚本名）
ExecStartPost = scripta.service
# 假设网络断开是运行脚本scriptb
ExecStopPost = scriptb.service
```

- [ ] 如何通过systemd设置实现一个脚本在任何情况下被杀死之后会立即重新启动？实现杀不死？
- [x] 设置脚本文件中的service区块中的restart字段，将其设置为always，即不管是什么退出原因，总是重启

### 五、实验问题
- [ ] 第一遍未录制视频练习熟悉命令代码，熟悉后进行相关设置后再未重启虚拟机即Ubuntu18.04server的状态下使用命令`asciinema rec`启动asciinema终端录制，出现错误提示

![](/Linux系统与网络管理/chap0x03/images/QUE-1.png)

- [x] 推测可能在较前systemd命令行练习中更改设置即

![](/Linux系统与网络管理/chap0x03/images/QUE-2.png)

   - 尝试通过命令`sudo localectl set-locale LANG=en_US.utf8`重新设置与进行配置相关文等操作均件未能解决该问题，重新启动虚拟机后恢复asciinema可执行环境
- [ ] 在进行实验自查清单的第四个即「如何实现开机自动挂载Virtualbox的共享目录分区？」尝试命令语句`sudo mount -t vboxsf ShareFolder ~/sharefolder`出现错误

![](/Linux系统与网络管理/chap0x03/images/QUE-3.png)

- [x] 搜索资料，尝试执行命令`ll /sbin/mount*`查看/sbin/mount.<type>文件

![](/Linux系统与网络管理/chap0x03/images/QUE-4.png)


- 执行`sudo apt-get install nfs-common`，再次查看`ll /sbin/mount*`，此时产生新的文件，再次执行命令`sudo mount -t vboxsf ShareFolder ~/sharefolder`问题未解决

![](/Linux系统与网络管理/chap0x03/images/QUE-5.png)

- 执行`sudo apt-get install virtualbox-guest-utils`问题得到解决

![](/Linux系统与网络管理/chap0x03/images/QUE-6.png)

### 六、实验参考
- [Systemd 入门教程：命令篇 by 阮一峰的网络日志](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)
- [Systemd 入门教程：实战篇 by 阮一峰的网络日志](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)
- [CUCCS/linux-2019-jckling](https://github.com/CUCCS/linux-2019-jckling/blob/02cda23fbddc44db254fe78b4de53a6dbe6e2f5e/0x03/%E5%AE%9E%E9%AA%8C%E6%8A%A5%E5%91%8A.md)
- [Virtualbox下linux虚拟机共享文件夹挂载](https://www.jianshu.com/p/39327c9ea368)