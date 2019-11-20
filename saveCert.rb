require "spaceship"
require 'openssl'
require "mysql2"
require 'pathname'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/globalConfig'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/userLogin'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/mysqlInstance'


#参考 https://github.com/fastlane/fastlane/blob/master/spaceship/docs/DeveloperPortal.md
# 设置 ser证书 和 上传p12文件
# 运行方式 ruby saveCert.rb  apuid username password p12

apuid = ARGV[0].to_s;
username = ARGV[1].to_s;
password = ARGV[2].to_s;

# 绝对路径
p12Path = ARGV[3].to_s;

certificateId = ''
clientKey = '/client_key.pem';
privateKey = '/private_key.pem';

begin
	ulogin = UserLogin.new(username, password, 1)
	ulogin.login()

    # 获取所有证书
    certificates = Spaceship::Portal.certificate.all

    if certificates.empty?
        #创建一个新证书
        csr, pkey = Spaceship::Portal.certificate.create_certificate_signing_request
        certificateObj = Spaceship::Portal.certificate.production.create!(csr: csr)
        certificateId = certificateObj.id
        cTime = certificateObj.created
        eTime = certificateObj.expires

    #   载入证书
        certificate = csr

        keyPath = GlobalConfig::ROOT_KEY + '/applesign/' + username + '/' + certificateId
        system "mkdir -p #{keyPath}"
        system "chmod 777 #{keyPath}"


    #   写入证书
        x509_certificate = certificateObj.download

        # cer证书
        File.write(keyPath + "/#{certificateId}.csr", csr.to_der)
        # 私钥
        File.write(keyPath + "/#{certificateId}.pkey", pkey.to_pem)

        # p12文件
        p12Key =  "/#{certificateId}.p12";
        p12Path = keyPath + p12Key
        p12 = OpenSSL::PKCS12.create('', 'production', pkey, x509_certificate)
        File.write(p12Path, p12.to_der)

        # x509_cer
        x509_cert_path = keyPath + "/#{certificateId}.x509_cert_path.pem"
        File.write(x509_cert_path, x509_certificate.to_pem + pkey.to_pem)

    else
        if p12Path.empty?
           raise  'p12Path 文件不存在'
        end

        certificateObj = Spaceship::Portal.certificate.production.all.first
        certificateId = certificateObj.id
        cTime = certificateObj.created
        eTime = certificateObj.expires

        keyPath = GlobalConfig::ROOT_KEY + '/applesign/' + username + '/' + certificateId
        system "mkdir -p #{keyPath}"
        system "chmod 777 #{keyPath}"

    end


    #  isign_export_creds.sh 证书.p12
    #  openssl pkcs12 -in $p12_path -out $target_cert_path -clcerts -nokeys
    #  openssl pkcs12 -in $p12_path -out $target_key_path -nocerts -nodes

    # puts  "openssl pkcs12 -password pass: -in #{p12Path} -out #{keyPath + clientKey} -clcerts -nokeys"

    output =  system "openssl pkcs12 -password pass: -in #{p12Path} -out #{keyPath + clientKey} -clcerts -nokeys"
    if !output
        raise puts  "openssl pkcs12  -password pass: -in #{p12Path} -out #{keyPath + clientKey} -clcerts -nokeys  失败"
    end

    output = system "openssl pkcs12  -password pass: -in #{p12Path} -out #{keyPath + privateKey} -nocerts -nodes"
    if !output
        raise puts  "openssl pkcs12  -password pass: -in #{p12Path} -out #{keyPath + privateKey} -nocerts -nodes  失败"
    end


    clientKey = '/applesign/' + username + '/' + certificateId + clientKey;
    privateKey =  '/applesign/' + username + '/' + certificateId + privateKey;



    # 更新mysql
    client = MysqlInstance.instance.getClient();

    #查询 证书id是否存在
    results = client.query("SELECT id FROM apple_developer_cer WHERE certificate_id= '#{certificateId}'")
    if results.any?
        #存在 更新
        client.query("update apple_developer_cer set certificate_pem = '#{clientKey}', key_pem = '#{privateKey}', c_time = '#{cTime}', e_time = '#{eTime}' where certificate_id = '#{certificateId}'")
    else
        #不存在保存
        client.query("insert into apple_developer_cer (apuid, certificate_id, certificate_pem, key_pem, c_time, e_time)values(#{apuid}, '#{certificateId}', '#{clientKey}', '#{privateKey}', '#{cTime}', '#{eTime}')")
    end

rescue Exception  => e
    puts "Trace message: #{e.errstr}"
else
    puts "Success message: 保存证书成功"
ensure
     # 断开与服务器的连接
    # MysqlInstance.instance.close()
end










