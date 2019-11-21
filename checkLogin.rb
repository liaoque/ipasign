require "spaceship"
require "mysql2"

require 'pathname'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/userLogin'

username = ARGV[0]
pwd = ARGV[1]

ulogin = UserLogin.new(username, pwd, 5)
ulogin.setShowTime(1)
ulogin.login()



