require "spaceship"
require 'pathname'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/globalConfig'

# certificate_pem key_pem 所使用的的p12文件 必须和 mobileprovision的cer签名文件一致
# 否则重新签名后也无法使用
# 运行方式 ruby saveCert.rb  username uuid inFile bundleId certificateId mobileProvision certificatePem keyPem



#开发者帐号
username = ARGV[0].to_s;
#用户duid
uuid = ARGV[1].to_s;
#打包文件
inFile = ARGV[2].to_s;
#包名
bundleId = ARGV[3].to_s;
certificateId = ARGV[4].to_s;

#相对路径
mobileProvision = ARGV[5].to_s;
certificatePem = ARGV[6].to_s;
keyPem = ARGV[7].to_s;

gid = 0;
gameName = bundleId;




#加入打包日志
cTime = Time.now
eTime = cTime + 31536000

# 更新mysql
begin

    # isign  -c /path/to/mycert.pem -k ~/mykey.pem -p path/to/my.mobileprovision -o   my222.ipa lcfh_allDis.ipa
    outFile = "/applesign/#{username}/#{certificateId}/#{gid}/#{uuid}_#{cTime.strftime("%Y%m%d%H%M%S")}.ipa"
    _outFile = GlobalConfig::ROOT_KEY + outFile

    keyPath = GlobalConfig::ROOT_KEY +  "/applesign/#{username}/#{certificateId}/#{gid}"
    system "mkdir -p #{keyPath}"
    system "chmod 777 #{keyPath}"


    certificatePem = GlobalConfig::ROOT_KEY + certificatePem
    mobileProvision = GlobalConfig::ROOT_KEY + mobileProvision
    keyPem = GlobalConfig::ROOT_KEY + keyPem

    system "rm -rf #{_outFile}"

    # puts "/usr/bin/isign   -c #{certificatePem} -k #{keyPem} -p #{mobileProvision} -o #{_outFile} #{inFile}"
    system "/usr/bin/isign   -c #{certificatePem} -k #{keyPem} -p #{mobileProvision} -o #{_outFile} #{inFile}"


    plist = "/applesign/#{username}/#{certificateId}/#{gid}/#{uuid}_#{cTime.strftime("%Y%m%d%H%M%S")}.plist"

    url = GlobalConfig::ROOT_IMG_PATH + outFile
    File.open(GlobalConfig::ROOT_KEY + plist, "w+") do |aFile|
          aFile.puts <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>assets</key>
			<array>
				<dict>
					<key>kind</key>
					<string>software-package</string>
					<key>url</key>
					<string>#{url}</string>
				</dict>
			</array>
			<key>metadata</key>
			<dict>
				<key>bundle-identifier</key>
				<string>#{bundleId}</string>
				<key>bundle-version</key>
				<string>1.0</string>
				<key>kind</key>
				<string>software</string>
				<key>title</key>
				<string>#{gameName}</string>
			</dict>
		</dict>
	</array>
</dict>
</plist>
EOF
    end

rescue Exception  => e
     puts "Trace message: #{e}"
else
     puts outFile 
     puts GlobalConfig::ROOT_KEY + plist
ensure
     # 断开与服务器的连接
end





