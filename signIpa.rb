require "spaceship"
require "mysql2"
require 'pathname'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/mysqlConfig'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/globalConfig'

# certificate_pem key_pem 所使用的的p12文件 必须和 mobileprovision的cer签名文件一致
# 否则重新签名后也无法使用


inFile = ARGV[0];
uid = ARGV[1];
uuid = ARGV[2];
gid = ARGV[3];
gameName = ARGV[4];
bundleId = ARGV[5];

#加入打包日志
cTime = Time.now
eTime = cTime + 31536000

# 更新mysql
begin
    client = Mysql2::Client.new(
        :host     => MysqlConfig::HOST,     # 主机
        :username => MysqlConfig::USER,      # 用户名
        :password => MysqlConfig::PASSWORD,    # 密码
        :database => MysqlConfig::DBNAME,      # 数据库
        :encoding => MysqlConfig::CHARSET      # 编码
    )

    #寻找对应的开发者
    results = client.query("SELECT apuid FROM apple_developer_uuid WHERE uuid='#{uuid}' limit 1")
    if !results.any?
         raise "设备号: #{uuid} 不存在"
    end

    apuid = results.first['apuid']
    results = client.query("SELECT user FROM apple_developer WHERE apuid='#{apuid}' limit 1")
    if !results.any?
         raise "设备号: #{uuid} 不存在"
    end
    username = results.first['user']

    #寻找对应的授权文件
   # puts "SELECT mobileprovision,certificate_id  FROM apple_developer_mobileprovision WHERE apuid= '#{apuid}'"
    results = client.query("SELECT mobileprovision,certificate_id  FROM apple_developer_mobileprovision WHERE apuid= '#{apuid}'")
    if !results.any?
        raise "mobileprovision 不存在"
    end

    mobileProvision = results.first['mobileprovision']
    certificateId = results.first['certificate_id']

   # puts "SELECT certificate_pem,key_pem FROM apple_developer_cer WHERE certificate_id= '#{certificateId}'"
    results = client.query("SELECT certificate_pem,key_pem FROM apple_developer_cer WHERE certificate_id= '#{certificateId}'")
    if !results.any?
        raise "certificate_id: #{certificate_id} 不存在"
    end

    certificatePem = results.first['certificate_pem']
    keyPem = results.first['key_pem']

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

    results = client.query("insert into apple_developer_ipa_log (uid, uuid, gid, apuid, certificate_id, certificate_pem, key_pem, mobileprovision, source_ipa, to_ipa, plist, build_id, c_time, e_time)values('#{uid}', '#{uuid}', '#{gid}',  '#{apuid}', '#{certificateId}', '#{certificatePem}', '#{keyPem}', '#{mobileProvision}', '#{inFile}', '#{outFile}', '#{plist}', '#{bundleId}', '#{cTime.strftime("%Y-%m-%d %H:%M:%S")}', '#{eTime.strftime("%Y-%m-%d %H:%M:%S")}')")

rescue Exception  => e
     puts "Trace message: #{e}"
else
     puts outFile
ensure
     # 断开与服务器的连接
     client.close if client
end





