### 超级签解决方案
#### 该解决方案不支持手机验证码自动验证，所以使用带有短信验证码的开发者帐号时， 先执行 `checkLogin.rb 开发者帐号 开发者密码` 手动填写一次验证码， 下次就不需要在输入了

##### 文件说明
1. addUUid.rb 增加设备号, 增加 Bundle id 生成 设备授权文件 mobileprovision
2. checkLogin.rb 检查苹果帐号 是否可以正常登录
3. getCertificateId.rb 获取苹果账号下的 描述文件
3. globalConfig.rb 路径相关的基本配置
4. mysqlConfig.rb 相关mysql配置
5. saveCert.rb 根据p12 文件，生成相对应的 私钥和证书
6. signIpa.rb 重新签名 ipa包
7. signMobileConfig.rb 签名 mobileconfig 用来获取用户设备码


##### 执行步骤
1. 执行 checkLogin
2. 保存 saveCert p12
3. 添加 addUUid 且更新 profile
4. 签名 signIpa

##### 注意
1. certificate_pem key_pem 所使用的的p12文件 必须和 mobileprovision的cer签名文件一致， 否则重新签名后也无法使用
2. 最好是由脚本创建这样就不会有以上这个问题
3. 如果需手动上传p12， 需要保证 两者一致，如果有误 请手动把 certificate_id 调整正确
4. getCertificateId.rb 该脚本可查看 certificate_id


##### 环境安装
> 服务器系统版本 centos 7.2
```shell
wget https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.4.tar.gz
tar -zxvf ruby-2.6.4.tar.gz
cd ruby-2.6.4
./configure --prefix=/usr/local/ruby-2.6.4
make && make install

ln -s /usr/local/ruby-2.6.4/bin/ruby /usr/bin/ruby
ln -s /usr/local/ruby-2.6.4/bin/gem /usr/bin/gem

gem install fastlane
gem install pry
gem install spaceship
gem install pry-coolline
gem install rails
gem install dbi
gem install mysql2
gem install dbd-mysql

yum install zip

python 2.7的环境, 不能是3.0的环境
pip install isign 不能使用这个安装
请使用
git clone https://github.com/apperian/isign
sh version.sh
python setup.py build
python setup.py install

```
更详细的请看： https://blog.csdn.net/LiaoQuesg/article/details/101219984

