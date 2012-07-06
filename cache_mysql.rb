#require 'rubygems'
#require "dbi"

#sample video url
#http://av.vimeo.com/80828/891/102736782.mp4?aksessionid=117a13fdfd841d996f3c3fca570cadab&token=1339771402_ddf4d971382dd0501fc8273446652d71
class Cache
	def initialize
	@host = "localhost"
	@db = "ytcache"
	@user = "ytcache"
	@password = "ytcache"
	@port = 3306
	end
	
	def setvid(url,vid)
	#REPLACE INTO `temp` (videoId, url) values  (vid,uri);
	q = "CALL seturl ('" + vid + "', '" + url + "');";

		commit(q)
	end

	def geturl(vid)
	   #SELECT url FROM temp WHERE videoId = _id ;
	   q = "CALL geturl ('" + vid + "' );"
		return commit(q) 
	end
	
	def vimid(url)
			m = url.match(/.*\.com\/(.*)(\?.*)/)
			if m[1]
				return m[1]
			else
				return nil
			end
	end

	def ytimg(url)
		m = url.match(/.*\.ytimg.com\/(.*)/)
		if m[1]
			return m[1]
		else
			return nil
		end
	end
	
	def ytvid(url)
		vid = nil;
		
		def getid(url)
			m = url.match(/(id\=[a-zA-Z0-9\-\_]+)/)
			return m.to_s if m != nil
		end
		
		def getitag(url)
			m = url.match(/(itag\=[0-9\-\_]+)/)
			return m.to_s if m != nil
		end
		
		def getrange(url)
			m = url.match(/(range\=[0-9\-]+)/)
			return m.to_s if m != nil
		end
		
		def getredirect(url)
			m = url.match(/(redirect\=)([a-zA-Z0-9\-\_]+)/)
			return (m.to_s + Time.now.to_i.to_s) if m != nil
		end
	
		id = getid(url)
		itag = getitag(url)
		range = getrange(url)
		redirect = redirect(url)
		if id == nil
			return nil
		else	
			vid = id
		end
		if itag != nil
			vid = vid + "&" + itag
		end
		if range != nil
			vid = vid + "&" + range
		end
		if redirect != nil
			vid = vid + "&" + redirect
		end
				
				
	end
	
	private
	def  commit(q)
		dbh = Mysql.new(@host, @user, @password , @db,@port, nil, Mysql::CLIENT_MULTI_RESULTS)
		#dbh=Mysql.init
		#dbh.real_connect(@host, @db, @user, @password,@port,nil,Mysql::CLIENT_MULTI_RESULTS)
		#dbh.query_with_result=false
		begin
			rs = dbh.query(q)
		rescue Mysql::Error => e 
			no_more_results=true
		end 
		if rs !=nil
			result = rs.fetch_row 
			rs.free
			return result[0] 
		end
		return nil
		
		#more_results?
		#next_result

		#begin
		#	  rs=dbh.use_result
		#	rescue Mysql::Error => e 
		#	  no_more_results=true
		#	end 
		#if rs !=nil
		#	result = rs.fetch_row 
		#	rs.free
		#	return result[0] 
		#end
	end

end
 
 
#http://i4.ytimg.com/sb/gEqYVmM941I/storyboard3_L2/M2.jpg?sigh=YM3vUDg0_555oIdiL5AlOYdwors
#http://i4.ytimg.com/sb/kwkSEaE2pdc/storyboard3_L2/M1.jpg?sigh=fyPjsOvoVWAX6X9Xffrs4Iupg7M