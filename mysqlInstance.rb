require "mysql2"
require 'pathname'
require Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/mysqlConfig'
require 'singleton'


class MysqlInstance
	include Singleton
	@@client = nil

	def getClient()
		if !@@client
			@@client = Mysql2::Client.new(
				:host     => MysqlConfig::HOST,     # 主机
				:username => MysqlConfig::USER,      # 用户名
				:password => MysqlConfig::PASSWORD,    # 密码
				:database => MysqlConfig::DBNAME,      # 数据库
				:encoding => MysqlConfig::CHARSET      # 编码
			)
		end
		return @@client
	end
	
	def close()
		if @@client
			@@client.close
		end
		@@client = nil
	end
end

END{
	MysqlInstance.instance.close();
}