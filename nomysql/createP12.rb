require "spaceship"
require 'openssl'

require 'pathname'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/globalConfig'


#参考 https://github.com/fastlane/fastlane/blob/master/spaceship/docs/DeveloperPortal.md
# 设置 ser证书 和 上传p12文件
# 运行方式 ruby saveCert.rb  apuid username password certificateId p12


username = ARGV[0].to_s;
password = ARGV[1].to_s;

certificateId = ARGV[2].to_s;
# 绝对路径
p12Path = ARGV[3].to_s;

begin
    Spaceship::Portal.login(username, password)

	#创建一个新证书
	csr, pkey = Spaceship::Portal.certificate.create_certificate_signing_request
	certificateObj = Spaceship::Portal.certificate.production.create!(csr: csr)
	certificateId = certificateObj.id
	cTime = certificateObj.created
	eTime = certificateObj.expires

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

rescue Exception  => e
    puts "Trace message: #{e.errstr}"
else
    puts "Success message: p12创建成功。"  
    puts "p12 PATH：#{p12Path}"  
ensure
     # 断开与服务器的连接
end










