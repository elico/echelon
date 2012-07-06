#require 'rubygems'
#require "dbi"

#sample video url
#http://av.vimeo.com/80828/891/102736782.mp4?aksessionid=117a13fdfd841d996f3c3fca570cadab&token=1339771402_ddf4d971382dd0501fc8273446652d71

class Filtering
	def initialize
	@host = "localhost"
	@db = "filter"
	@user = "filter"
	@password = "filter"
	@port = 3306
	end

	def dstdomain(dom)
		status = 0
		dom = dom.reverse
		tld = dom.match(/([a-zA-Z\-\_]+\.[a-zA-Z\-\_]+)(\.|.*)/)[1]
		db = connect
		statement = db.prepare "SELECT dom FROM acl WHERE dom like ?"
		tld = tld + "%"
		statement.execute tld
		statement.each do |acl|
			if match? acl[0],dom
				status = 1
				break
			end
		end
		statement.close
		db.close
		return status
	end
	
	def bdomain(dom)
		status = 0
		dom = dom.reverse
		tld = dom.match(/([a-zA-Z0-9\-\_]+\.[a-zA-Z0-9\-\_]+)(\.|.*)/)[1]
		db = connect
		statement = db.prepare "SELECT dom FROM filter WHERE dom like ?"
		tld = tld + "%"
		statement.execute tld
		statement.each do |acl|
			if fmatch? acl[0],dom
				status = 1
				break
			end
		end
		statement.close
		db.close
		return status
	end
	
	# @param domacl = reversed domain acl
	# @param dom = reversed domain to check
	private
	def match? domacl, dom
		dom == domacl ||
		  domacl.endwith?(".") && dom.start_with?(domacl.chop) && dom.start_with?(domacl)
	end 
	
	def fmatch? domacl, dom
		dom == domacl ||
		dom.start_with?(domacl) && dom.start_with?(domacl + ".")
	end 
	
	
	private
	#this method is used for stored procedures
	def  commit(q)
		dbh=Mysql.init
		dbh.real_connect(@host, @user, @password, @db,@port,nil,Mysql::CLIENT_MULTI_RESULTS)
		dbh.query_with_result=false
		dbh.query(q)
			begin
			  rs = dbh.use_result
			rescue Mysql::Error => e 
			  no_more_results=true
			end 
		if rs.fetch_row == nil
			return nil
		else
			return rs
		end
	end

	def connect
		begin
			dbh = Mysql.new(@host, @user, @password, @db)
		rescue Mysql::Error
			puts "Oh noes! We could not connect to our database. -_-;;"
		end
		return dbh
	end

end

#sql notes
	#REPLACE INTO `temp` (videoId, url) values  (vid,uri);
#	q = "CALL seturl ('" + vid + "', '" + url + "');";
#	qlite = "insert or REPLACE INTO temp (videoId, url) values  ('" + vid + "','" + url + "')"

	   #SELECT url FROM temp WHERE videoId = _id ;
#	   q = "CALL geturl ('" + vid + "' );"
	#   qlite = "SELECT url FROM temp WHERE videoId = + " + vid
	
	
	#load data infile '/tmp/doms.txt' into table test1 (@var1) set dom= reverse(@var1);
	#load data infile'/opt/echelon-mod/blacklist/blacklists/spyware/domains' into table test1 (@var1) set dom= reverse(@var1);
 #'/opt/echelon-mod/blacklist/blacklists/spyware/domains'
