#!/usr/bin/ruby
## -*- coding: UTF-8 -*-
# 运行方式 ruby getCertificateId.rb  username password


require "spaceship"

username = ARGV[0];
password = ARGV[1];

Spaceship.login(username, password)
devices = Spaceship::Portal.certificate.production.all
puts devices
