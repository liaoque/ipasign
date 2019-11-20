#!/usr/bin/ruby
## -*- coding: UTF-8 -*-
# 运行方式 ruby getCertificateId.rb  username password

require 'pathname'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/userLogin'

username = ARGV[0]
pwd = ARGV[1]


begin
	ulogin = UserLogin.new(username, pwd, 1)
	ulogin.login()
	devices = Spaceship::Portal.certificate.production.all
rescue Exception  => e
    puts "Trace message: #{e.message}"
else
    puts devices
ensure
	
end