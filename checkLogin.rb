require "spaceship"
require "mysql2"

require 'pathname'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/mysqlConfig'

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
            # 正常退出 更新数据库
            client = Mysql2::Client.new(
                :host     => MysqlConfig::HOST,     # 主机
                :username => MysqlConfig::USER,      # 用户名
                :password => MysqlConfig::PASSWORD,    # 密码
                :database => MysqlConfig::DBNAME,      # 数据库
                :encoding => MysqlConfig::CHARSET      # 编码
            )

          #  client.query("update kxwweb.apple_developer set checked = 1 where user = #{username}")
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
	# client.query("update kxwweb.apple_developer set checked = 2 where user = #{username}")
     puts "Trace message: #{e.message}"
else
     puts "Success message: 帐号密码校验成功"
ensure
     # 断开与服务器的连接
     client.close if client
end



