require "spaceship"
require 'pathname'


username = ARGV[0]
pwd = ARGV[1]

begin
    thr = Thread.new{ Spaceship::Portal.login(username, pwd) }
    #定时检查
    for i in 0..11
        sleep 5

        # 检查 线程是否在运行
        case thr.status
        when false
		
            break
        when nil
            raise "验证错误：退出"
            break
        else
             puts Time.new
        end
    end

    if thr.status
        #强制结束线程
        thr.exit
        raise "验证手机号超时"
    end
rescue Exception  => e
     puts "Trace message: #{e.message}"
else
     puts "Success message: 帐号密码校验成功"
ensure
     # 断开与服务器的连接
end



