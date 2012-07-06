#!/usr/bin/ruby
# ---------------------------------------------------------------------------------------
# Echelon
# ICAP Prototype Server
# - By Alex Levinson
# - May 25th, 2012
# ---------------------------------------------------------------------------------------
require 'rubygems'
require 'dbi'
require 'mysql'
#require 'sqlite3'


require 'bundler'
require 'syslog'
require 'settingslogic'
Bundler.require(:icap)



#insert here all the instance variables for the software.
require './filter.rb'
require './cache_mysql.rb'
$domcheck = Filtering.new	
$cache = Cache.new

# ---------------------------------------------------------------------------------------


class Settings < Settingslogic
  if ARGV.size == 0
  	  if File.exist?"./config/settings.yml" 
	  puts "default setttings is being used"
	  puts "./config/settings.yml"
	  source "./config/settings.yml"
	  load!
	else
	  puts "no settings file was defined in the start command"
	  puts "or exists in the default directory"
	  exit 1
	end
  else
    puts "using config file: " + ARGV[0]
    source "#{ARGV[0]}"
    load!
  end
end
# ---------------------------------------------------------------------------------------
class Echelon < EM::Connection


@debug = (Settings.debug == 1)
@request = { "Request" =>{}, "Headers" => [] }
@resp = ""


  def post_init
    cleanup
  end

  def receive_data(packet)
	log("packet recived") if @debug
   @data_status = 0
    @data << packet
	log("recived data: " + @data ) if @debug
  	if @icap_header[:data] == "" and pos = (@data =~ /\r\n\r\n/)
      @icap_header[:data] = @data[0..pos+1]
      if @icap_header[:data] =~ /^((OPTIONS|REQMOD|RESPMOD) icap:\/\/([A-Za-z0-9\.\-:]+)([^ ]+) ICAP\/1\.0)\r\n/
        req                 = $1
        @icap_header[:mode] = $2
        @icap_header[:host] = $3
        @icap_header[:path] = $4
        @icap_header[:data][req.size+2..@icap_header[:data].size-1].scan(/([^:]+): (.+)\r\n/).each do |h|
          @icap_header[:hdr][h[0]] = h[1]
      end
      else
        log("Error with ICAP header!") if @debug
		# exit 1
		# puts "Error with ICAP header! Exiting!" ; exit 1
        # TODO: Having problems when this uncommented
      end
      log(@data) if @debug
	  @data = @data[pos+4..@data.size-1]
	  log(@data) if @debug
    end
	log(@icap_header) if @debug

	log("Starting case") if @debug 
    case @icap_header[:mode]
    when 'OPTIONS'
      log("OPTIONS case")  if @debug 
      send_data("ICAP/1.0 200 OK\r\nMethods: REQMOD\r\nISTag: \"Echelon-mod-0.1\"\r\nOptions-TTL: 30\r\nMax-Connections: 700\r\nAllow: 204\r\nPreview: 0\r\n\r\n")
      cleanup
    when 'REQMOD'
	  log("REQMOD case")  if @debug
	  orginizedata
	  log(@request) if @debug
		  case @request["Request"]["Method"]
			when /(GET|HEAD)/
			log("method is GET or HEAD") if @debug
			 #newdata =  seturl("http://www.yahoo.com/",request,@request[Headers])
			 #newdata = ""
			 
#######################################################
#insert here your code
#sample
# seturl("http://google.co.il/") if matcher(/^http:\/\/www\.google\.com/)
#
#matcher is a class to match regular expresions for validity only if true or false
#a more complex options can be written manullay.
###
# one more sample
#  if matcher(/^http:\/\/www\.google\.com/) 
#	uri = geturl.match(/http:\/\/[a-z\.]+\.com\/(.*)/)[1]
#	seturl("http://www.google.co.il/" + uri)
#	end
#
#  turns into these
#1339602675.159    305 192.168.10.100 TCP_MISS/404 1243 GET http://www.google.co.il/www - DIRECT/173.194.69.94 text/html
#1339602675.317    122 192.168.10.100 TCP_MISS/200 7618 GET http://www.google.co.il/images/errors/robot.png - DIRECT/173.194.69.94 image/png
#
#
# methods: 
###
# seturl(url)
# set rewrites the url in the request and also the host name on the request header.
###
#  @param header - the name of the header
#  @param data - the data you want to set in the header.
#  setheader(header,data)  
# if an header exists fills the new data. 
# for now you can only change or add a new header using:
###
#  @param header - the name of the header
#  @param data - the data you want to set in the header.
# addheader(header,data)
###
# geturl
# returns the full url of the request as a string
###

 #http://i4.ytimg.com/sb/gEqYVmM941I/storyboard3_L2/M2.jpg?sigh=YM3vUDg0_555oIdiL5AlOYdwors


case
when (@icap_header[:path].include? "cache") 
	case 

	when (geturl.match(/http:\/\/.*\.c\.youtube\.com\/videoplayback\?.*id\=.*/) )


	when (geturl.match(/http:\/\/.*\.ytimg\.com\/vi\/.*/))


	when ( geturl.match(/http:\/\/av\.vimeo.com\/\.*/) )

	else


	end

when  ( @icap_header[:path].include? "vimeoexternal" )
	vid = $cache.vimid(geturl)
	$cache.setvid(geturl, "http://vimeo.squid.internal/" + vid,)
	seturl("http://vimeo.squid.internal/" + vid) 

when  ( @icap_header[:path].include? "ytimgexternal" )
	vid = $cache.ytimg(geturl)
	$cache.setvid(geturl, "http://ytimg.squid.internal/" + vid,)
	seturl("http://ytimg.squid.internal/" + vid)

when  ( @icap_header[:path].include? "vimeointernal" )
	log("vimeo internal") if @debug
	url = $cache.geturl(geturl)
	log(url)
	seturl(url) if url != nil

when  ( @icap_header[:path].include? "ytimginternal" )
	log("ytimg internal") if @debug
	url =  $cache.geturl(geturl)
	log(url)
	seturl(url) if url != nil

when  ( @icap_header[:path].include? "smpfilter" )
    log("basic filter check") if @debug
	log(geturl) if @debug
	test = $domcheck.bdomain(gethost)
	log("level is: " + test.to_s)
 	set302("http://www1.ngtech.co.il/302porn.html") if  test != 0
	puts $domcheck.domain(gethost) if @debug

when ( @icap_header[:path].include? "redirect" )
	log("302") if @debug
	set302("http://www1.ngtech.co.il/302.html")
else

end



#####################################################
			 case
				when (@data_status  == 1)
				log("Request was changed") if @debug
				log(@request) if @debug
				preresp 
				log(@request) if @debug
				send_data(compreq)
				when (@data_status == 2)
				log("Request was changed to 302 response") if @debug
				log(@request) if @debug
				send_data(compresp)
			else
			  log("GET or HEAD data wasnt modified") if @debug
			  log ("No Modification for: #{@request}")  if @debug
			  nocontent
			end
		else
		    log("method is not GET") if @debug
			log(@request["Request"]["Method"]) if @debug
			log ( "No Modification for: #{@request}")
			nocontent
		end
    when 'RESPMOD'
	  log("RESPMOD case") if @debug
   	  nocontent
    else
		log("else/RESPMOD") if @debug
    end
	cleanup
  end
  
  
  def nocontent
    send_data("ICAP/1.0 204 No Content.\r\n\r\n")
	log("no content 204 sent") if @debug
  end

  def cleanup
	log("starting cleanup") if @debug
	@data_status = 0
    @data        = ""
    @body        = ""
    @icap_header = { 
      :data => "", 
      :mode => "", 
      :path => "", 
      :hdr  => {}
    }
	@request = { "Request" =>{}, "Headers" => [] }
	@resp = ""
  end

  def orginizedata
	  req_raw  = @data.dup.split(/\r\n/)
	  @request["Request"] = parserequest(req_raw[0])
      req_raw[1..-1].each do |line|
        line.scan(/([^:]+): (.+)/).each do |h,c|
    	 @request["Headers"] <<  h
		 @request["Headers"] <<  c
	    end
	  end
  end
   
   def parserequest(req)
	k = req.scan(/(GET|POST|PUT|HEAD|PURGE)\ (http:\/\/.*)\ (.*)/)[0]
	log(k) if @debug
	h = {"Method" => k[0], "Url" => k[1], "Version"=> k[2]}
	log(h) if @debug
	log(h) if @debug
	return h
  end
  
  
  def compreq
 	#about the icap format:
	#the icap headers separated from the the response header with a clean line "\r\n"
	#the response header \end of the message ended with double clean lines "'\r\n\r\n"
	#
	#
	#
	#
	#  original compose
	#response = "ICAP/1.0 200 OK\r\nDate: #{Time.now.strftime("%a, %d %b %Y %X %Z")}\r\nServer: RubyICAP\r\nConnection: close\r\nEncapsulated: req-hdr=0, null-body=#{@data.bytesize}\r\n\r\n#{@data}"
	log("composing icap response") if @debug
	return  ("ICAP/1.0 200 OK\r\nDate: #{Time.now.strftime("%a, %d %b %Y %X %Z")}\r\nServer: RubyICAP\r\nEncapsulated: req-hdr=0, null-body=#{@request.bytesize}\r\nConnection: close\r\n\r\n#{@request}")
  end
   
   def compresp
 	#about the icap format:
	#the icap headers separated from the the response header with a clean line "\r\n"
	#the response header \end of the message ended with double clean lines "'\r\n\r\n"
	#
	#
	#
	#
	#  original compose
	#response = "ICAP/1.0 200 OK\r\nDate: #{Time.now.strftime("%a, %d %b %Y %X %Z")}\r\nServer: RubyICAP\r\nConnection: close\r\nEncapsulated: req-hdr=0, null-body=#{@data.bytesize}\r\n\r\n#{@data}"
	log("composing icap response") if @debug
	return  ("ICAP/1.0 200 OK\r\nDate: #{Time.now.strftime("%a, %d %b %Y %X %Z")}\r\nServer: RubyICAP\r\nEncapsulated: res-hdr=0, null-body=#{@request.bytesize}\r\nConnection: close\r\n\r\n#{@request}")
  end
   
  def set302(url)
  @data_status = 2
  @request = "HTTP/1.1 302 temporary redirect\r\nlocation: " + url + "\r\n\r\n"
  end
  
  def seturl(url)
    @request["Request"]["Url"] = url
	setheader("Host", extracthost(url) )
	@data_status = 1
	  
  end
 
	def geturl
	 return @request["Request"]["Url"] 
	end
 
  def gethost
	return getheader("Host")
  end
	def getheader(header)
		index = 0
		while index < @request["Headers"].size do
			if @request["Headers"][index] == header
				return @request["Headers"][index + 1]
			end
			index += 2
		end
		return "not exists"
    end
	
	def setheader(header,data)
		index = 0
		while index < @request["Headers"].size do
			if @request["Headers"][index] == header
			@request["Headers"][index + 1] = data
			return "changed"
			end
			index += 2
			
		end
			return "not exists"
	end
	
	def addheader(header, data)		
			@request["Headers"]<< header
			@request["Headers"]<< data
			return "changed"
		end
	
	  def preresp
		key = "" 
		key += @request["Request"]["Method"] + " " +  @request["Request"]["Url"] + " " +  @request["Request"]["Version"] + "\r\n"
		index = 0
		while index < @request["Headers"].size do
			key +=  @request["Headers"][index] + ": "
			index += 1
			key +=  @request["Headers"][index] + "\r\n"
			index += 1
		end
		key += "\r\n\r\n"
		@request = key
	  end
	
	def parsereq(request)
		log (request)
		return request.scan(/(GET|POST|PUT|HEAD)\ (http:\/\/.*)\ (.*)/)[0]
	end
	
		def divideurl(url)
		log(url)
			return url.scan(/^(http:\/\/)([0-9a-zA-Z\.\-\_]+)(\/.*)/)[0]
		end
	
	def extracthost(url)
		log (url)
		return divideurl(url)[1]
	end
	
	def matcher(regex)
		if regex.match(@request["Request"]["Url"])
			return true
		else
			return false
		end	
	end
	

end



def log(msg)
	Syslog.log(Syslog::LOG_ERR, "%s", msg)
end

def main
	Syslog.open('Ruby_Icap', Syslog::LOG_PID)
	log("Started")

		Settings.each do |l| 
		log(l)  
		end
	puts "== Ruby ICAP Server Started =="

	EM.run do
		EM.start_server Settings.host, Settings.port, Echelon
		if Settings.forks.size > 0
		forks = Settings.forks.to_i
		puts "... forking #{forks} times => #{2**forks} instances"
		forks.times { fork }
	 
		end

	end
end

main

