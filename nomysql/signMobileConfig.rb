require "spaceship"
require "mysql2"
require 'pathname'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/globalConfig'


#参考 https://github.com/fastlane/fastlane/blob/master/spaceship/docs/DeveloperPortal.md
# 运行方式 ruby saveCert.rb  mobileConfig 


#绝对路径
mobileConfig = ARGV[0].to_s;
gid = 0


begin

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
end




