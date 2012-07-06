#require 'rubygems'
#require "dbi"

#sample video url
#http://av.vimeo.com/80828/891/102736782.mp4?aksessionid=117a13fdfd841d996f3c3fca570cadab&token=1339771402_ddf4d971382dd0501fc8273446652d71
#http://o-o.preferred.bezeq-tlv1.v22.lscache8.c.youtube.com/videoplayback?upn=sZjnawryR0s&sparams=algorithm%2Cburst%2Ccp%2Cfactor%2Cid%2Cip%2Cipbits%2Citag%2Csource%2Cupn%2Cexpire&fexp=906717%2C914062%2C904825%2C907217%2C907335%2C921602%2C919306%2C922600%2C919316%2C920704%2C924500%2C924700%2C913542%2C919324%2C920706%2C907344%2C912706%2C902518&mt=1341535696&ms=au&algorithm=throttle-factor&itag=5&ip=109.0.0.0&burst=40&sver=3&signature=9C5478A96238A22C16CBA7B5CDFA76C3748A2597.AEAA0A86C32829350AC2DA80FA0611FD7B32943A&source=youtube&expire=1341557093&key=yt1&ipbits=8&factor=1.25&cp=U0hTRlVQVV9OTUNOM19NSllBOlU4SHJ1STdPWkda&id=5e46d00c2860997f

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
			dbh.close
			return result[0] 
		end
		dbh.close
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