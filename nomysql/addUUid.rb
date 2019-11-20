require "spaceship"
require 'openssl'
require 'pathname'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/globalConfig'

#参考 https://github.com/fastlane/fastlane/blob/master/spaceship/docs/DeveloperPortal.md
# 运行方式 ruby addUUid.rb  username password uuid bundleId certificateId

username = ARGV[0].to_s;
password = ARGV[1].to_s;
uuid = ARGV[2].to_s;
bundleId = ARGV[3].to_s;
certificateId = ARGV[4].to_s;


mobileprovision = '/sign.' + bundleId + '.mobileprovision'

def ad_hocCreate(bundleId, certificateId, username)
	cert = Spaceship::Portal.certificate.production.find(certificateId)
	if !cert
		raise "证书#{certificateObj['id']} 不存在"
	end


	#创建 ad_hoc
	Spaceship::Portal.provisioning_profile.ad_hoc.create!(bundle_id: bundleId, certificate: cert, name: username)
	sleep 1
end

begin
    # 绝对路径

    Spaceship::Portal.login(username, password)

    #添加 bundleId
    app = Spaceship::Portal.app.find(bundleId)
    if !app
        app = Spaceship::Portal.app.create!(bundle_id: bundleId, name: bundleId)
    end

    # 获取所有证书
    certificates = Spaceship::Portal.certificate.all

    if certificates.empty?
        raise "证书为空"
    end

    #如果uuid不存在则添加uuid
    if !Spaceship::Portal.device.find_by_udid(uuid)
        Spaceship::Portal.device.create!(name:uuid, udid: uuid)

        #更新设备数量
        deviceLength = Spaceship::Portal.device.all.length
    end

    #遍历查找对应 bundleId 和 certificateId 的 profile
	Spaceship.provisioning_profile.ad_hoc.all.each do |p|
		#遍历查找对应 bundleId 和 certificateId 的 profile
		p.certificates.each do |cs|
		if cs.id == certificateId && p.app.bundle_id == bundleId
                $ad_hocProfile = p
                break
            end
		end
    end
	
	
	#ad_hoc 不存在
	if !defined? $ad_hocProfile
        ad_hocCreate(bundleId, certificateId, bundleId + '.' + certificateId)
		sleep 1
		$ad_hocProfile = Spaceship.provisioning_profile.ad_hoc.all.first
    end
	
	if !defined? $ad_hocProfile
		raise "ad_hoc profile 生成失败"
	end
	
	#设备号
	devices = Spaceship.device.all
	# 根据cert 证书创建
    #更新 ad_hoc
	$ad_hocProfile.devices = devices
	#$ad_hocProfile.update_service(Spaceship::Portal.app_service.push_notification.on)
	$ad_hocProfile.update!
	
	# 重新从线上获取数据
	Spaceship.provisioning_profile.ad_hoc.all.each do |p|
		if p.name == $ad_hocProfile.name
			# 根据cert 证书创建
			# profile 写到对应的文件夹,以便更新
			c_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
			mobileprovision =  '/applesign/' + username + '/' + certificateId + mobileprovision
			keyPath = GlobalConfig::ROOT_KEY +  '/applesign/' + username + '/' + certificateId
			system "mkdir -p #{keyPath}"
			system "chmod 777 #{keyPath}"
			
			File.write(GlobalConfig::ROOT_KEY + mobileprovision, p.download)
			break
		end
	
	end

rescue Exception  => e
     puts "Trace message: #{e}"
else
    puts "Success message: 添加成功" + GlobalConfig::ROOT_KEY + mobileprovision
ensure
     # 断开与服务器的连接
end




