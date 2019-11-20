require "spaceship"
require "mysql2"

require 'pathname'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/mysqlInstance'


class UserLogin
	@@showTime = 0;

	def initialize(username, password, sleep = 1)
		@username=username
		@password=password
		@sleep=sleep
	end
	
	def setShowTime(show = 1)
		@@showTime=show
	end
	
	def login()
		begin
			thr = Thread.new{ Spaceship::Portal.login(@username, @password) }
			#定时检查
			for i in 0..11
				sleep @sleep

				# 检查 线程是否在运行
				case thr.status
				when false
					# 正常退出 更新数据库
					client = MysqlInstance.instance.getClient();
					client.query("update kxwweb.apple_developer set checked = 1 where user = '#{@username}'")
					break
				when nil
					raise "验证错误：退出"
					break
				else
					puts Time.new if @@showTime
				end
			end

			if thr.status
				#强制结束线程
				thr.exit
			raise "验证手机号超时"
			end
		rescue Exception  => e
			# 更新帐号为锁定， 区分禁用和锁定， 锁定是暂时帐号验证不通过， 禁用是帐号不可用
			# 使用锁定策略可把需要验证码的验证的调整成锁定暂时不可用
			 client.query("update kxwweb.apple_developer set checked = 3 where user = '#{@username}")
			 puts "Trace message: #{e.message}"
		else
			puts "Success message: 帐号密码校验成功"
		ensure
			 # 断开与服务器的连接
			#MysqlInstance.instance.close()
		end	
	end
	
end
