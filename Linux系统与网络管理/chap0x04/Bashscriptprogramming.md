### 一、实验名称
Shell脚本编程
### 二、实验环境
- virtualbox
- Ubuntu 18.04 Server 64bit
- bash:bash-3.2
### 三、实验任务
#### 任务一
- 用bash编写一个图片批处理脚本，实现以下功能：
- 支持命令行参数方式使用不同功能
- 支持对指定目录下所有支持格式的图片文件进行批处理
- 支持以下常见图片批处理功能的单独使用或组合使用

```
1. 支持对jpeg格式图片进行图片质量压缩
2. 支持对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率
3. 支持对图片批量添加自定义文本水印
4. 支持批量重命名（统一添加文件名前缀或后缀，不影响原始文件扩展名）
5. 支持将png/svg图片统一转换为jpg格式图片
```
#### 任务二
- 用bash编写一个文本批处理脚本，对以下附件分别进行批量处理完成相应的数据统计任务：

- [2014世界杯运动员数据](https://sec.cuc.edu.cn/huangwei/course/LinuxSysAdmin/exp/chap0x04/worldcupplayerinfo.tsv)
- 统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
- 统计不同场上位置的球员数量、百分比
- 名字最长的球员是谁？名字最短的球员是谁？
- 年龄最大的球员是谁？年龄最小的球员是谁？

#### 任务三
- 用bash编写一个文本批处理脚本，对以下附件分别进行批量处理完成相应的数据统计任务：
- [Web服务器访问日志](https://sec.cuc.edu.cn/huangwei/course/LinuxSysAdmin/exp/chap0x04/web_log.tsv.7z)
- 统计访问来源主机TOP 100和分别对应出现的总次数
- 统计访问来源主机TOP 100 IP和分别对应出现的总次数
- 统计最频繁被访问的URL TOP 100
- 统计不同响应状态码的出现次数和对应百分比
- 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
- 给定URL输出TOP 100访问来源主机

### 四、实验结果
#### 任务一
- 查看帮助信息`bash imgpro -h`

![](/Linux系统与网络管理/chap0x04/images/1-1-1.png)

- 支持对jpeg格式图片进行图片质量压缩`bash imgpro -q 900 311.jpeg d333.jpeg`

![](/Linux系统与网络管理/chap0x04/images/1-2-1.png)

- 支持对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率`bash imgpro -r 1280*800 666.png d666.png`/`bash imgpro -r 1280*800 366.jpeg 333.jpeg`

![](/Linux系统与网络管理/chap0x04/images/1-3-1.png)
![](/Linux系统与网络管理/chap0x04/images/1-3-2.png)

- 支持对图片批量添加自定义文本水印`bash imgpro -w 366.jpeg 123456 w366.jpeg`

![](/Linux系统与网络管理/chap0x04/images/1-4-1.png)

- 支持批量重命名（统一添加文件名前缀或后缀，不影响原始文件扩展名）`bash imgpro -m 366.jpeg re366.jpeg`

![](/Linux系统与网络管理/chap0x04/images/1-5-1.png)

- 支持将png/svg图片统一转换为jpg格式图片`bash imgpro -c 666.png 333.jpg`

![](/Linux系统与网络管理/chap0x04/images/1-6-1.png)

#### 任务二
- 输出帮助信息`bash wip -h`

![](/Linux系统与网络管理/chap0x04/images/2-1-1.png)

- 统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比`bash wip -rage`

![](/Linux系统与网络管理/chap0x04/images/2-2-1.png)

- 统计不同场上位置的球员数量`bash wip -posi`

![](/Linux系统与网络管理/chap0x04/images/2-3-1.png)

- 名字最长的球员是谁？名字最短的球员是谁？`bash wip -name`

![](/Linux系统与网络管理/chap0x04/images/2-4-1.png)

- 年龄最大的球员是谁？年龄最小的球员是谁？`bash wip -tage`

![](/Linux系统与网络管理/chap0x04/images/2-5-1.png)

#### 任务三
- 输出帮助信息`bash wteb -h`

![](/Linux系统与网络管理/chap0x04/images/3-1-1.png)

- 统计访问来源主机TOP 100和分别对应出现的总次数`bash wteb -th`

![](/Linux系统与网络管理/chap0x04/images/3-2-1.png)

- 统计访问来源主机TOP 100 IP和分别对应出现的总次数`bash wteb -ti`

![](/Linux系统与网络管理/chap0x04/images/3-3-1.png)

- 统计最频繁被访问的URL TOP 100`bash wteb -tu`

![](/Linux系统与网络管理/chap0x04/images/3-4-1.png)

- 统计不同响应状态码的出现次数和对应百分比`bash wteb -sp`

![](/Linux系统与网络管理/chap0x04/images/3-5-1.png)

- 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数`bash wteb -su`

![](/Linux系统与网络管理/chap0x04/images/3-6-1.png)

- 给定URL输出TOP 100访问来源主机`bash wteb -gu /shuttle/resources/orbiters/discovery.html `

![](/Linux系统与网络管理/chap0x04/images/3-7-1.png)


### 六、参考
[BASH Programming - Introduction HOW-TO](http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO.html)

[magick](https://www.imagemagick.org/script/convert.php])

[Shell 传递参数](http://www.runoob.com/linux/linux-shell-passing-arguments.html)

[阮一峰 awk 入门教程](http://www.ruanyifeng.com/blog/2018/11/awk.html)

[Awk](http://www.grymoire.com/Unix/Awk.html)

[zjy-exp4](https://github.com/CUCCS/linux/tree/master/2017-1/zjy/exp4)
