require "spaceship"
require "mysql2"
require 'pathname'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/mysqlConfig'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/globalConfig'


#参考 https://github.com/fastlane/fastlane/blob/master/spaceship/docs/DeveloperPortal.md

#绝对路径
mobileConfig = ARGV[0].to_s;
gid = ARGV[1].to_s;


begin
=begin
    client = Mysql2::Client.new(
        :host     => MysqlConfig::HOST,     # 主机
        :username => MysqlConfig::USER,      # 用户名
        :password => MysqlConfig::PASSWORD,    # 密码
        :database => MysqlConfig::DBNAME,      # 数据库
        :encoding => MysqlConfig::CHARSET      # 编码
    )
=end

    #openssl smime -sign -in Example.mobileconfig -out SignedVerifyExample.mobileconfig -signer InnovCertificates.pem -certfile root.crt.pem -outform der -nodetach

     signMobileConfig = GlobalConfig::ROOT_KEY + "/applesign/#{gid}.sign.mobileconfig"
     InnovCertificates = GlobalConfig::ROOT_KEY + '/applesign/Intermediate.crt.pem'
     okwanPublicCrt = GlobalConfig::ROOT_KEY + '/applesign/mobileconfig_key/okwan.public.crt'
     okwanComKey = GlobalConfig::ROOT_KEY + '/applesign/mobileconfig_key/okwan.com.key'
     okwanComPem = GlobalConfig::ROOT_KEY + '/applesign/mobileconfig_key/okwan.com.pem'

     system "openssl smime -sign -in  #{mobileConfig} -out #{signMobileConfig} -signer #{okwanPublicCrt} -inkey #{okwanComKey} -certfile #{okwanComPem} -outform der -nodetach"


rescue Exception  => e
    puts "Trace message: #{e.errstr}"
else
    puts signMobileConfig
ensure
     # 断开与服务器的连接
     #client.close if client
end




