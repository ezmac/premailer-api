require 'rubygems'
require 'bundler'
Bundler.require
require 'sinatra'
require 'sinatra/streaming'
require 'sinatra/cross_origin'
require 'premailer'
require 'redis'
require 'json'

REDIS_HTML_EXPIRY = 600

REDIS_HOST = ENV['REDIS_HOST']
REDIS_PORT = ENV['REDIS_PORT']
REDIS_DB = ENV['REDIS_DB']
if REDIS_HOST.nil? || REDIS_PORT.nil? || REDIS_DB.nil?
  puts "Environment variables REDIS_HOST, REDIS_PORT and REDIS_DB are required."
  exit
else
  puts REDIS_HOST
  puts REDIS_PORT
  puts REDIS_DB

end
#https://github.com/premailer/premailer/blob/master/lib/premailer/premailer.rb#L178
#
###
#url	string	URL of the source file	
#html	string	Raw HTML source	
#adapter	string	Which document handler to use	hpricot (default) #nokogiri
#base_url	string	Base URL for converting relative links	
#line_length	int	Length of lines in the plain text version	Default is 65
#link_query_string	string	Query string appended to links	
#preserve_styles	boolean	Whether to preserve any link rel=stylesheet and style elements	true (default) #false
#remove_ids	string	Remove IDs from the HTML document?	true #false (default)
#remove_classes	string	Remove classes from the HTML document?	true #false (default)
#remove_comments	string	Remove comments from the HTML document?	true
#false (default)
#Receiving the response
###
#
configure do
  set :environment, 'production'
  enable :cross_origin
end
def respondWith(html)
  content_type :json
  { :html => "#{html}"} .to_json
end

def handleRequest(params)
end

get '/test/' do
  "this is your rack app"
end
get '/sinatra/test/' do
  "this is your rack app with prefix"
end

options "*" do
  response.headers["Allow"] = "GET,POST,OPTIONS"

  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"

  200
end


post '/api/0.1/documents' do
  premailer_opts={}
  if request.env['CONTENT_TYPE'] == 'application/json'
    requestBody = request.body.read
    if not requestBody.empty?
      body = JSON.parse requestBody
      html = body['html']
      url = body['url']
      premailer_opts =Hash[body.map{ |k, v| [k.to_sym, v] }] 
      premailer_opts.delete('html')
      premailer_opts.delete('url')
    else
      #LIAR!
      return "if you're going to send a content_type of 'application/json' send a body"
    end
  else
    html = params['html']
    url = params['url']
  end
  if url.nil?
    premailer_opts['with_html_string']=true
    premailer = Premailer.new(html, premailer_opts)
  else
    premailer = Premailer.new(url, premailer_opts)
  end

  Dir.mkdir('html') unless File.exists?('html')
  Dir.mkdir('txt') unless File.exists?('txt')

  # Write the HTML output to Redis
  htmlFilename = "#{SecureRandom.uuid}.html"
  htmlFilename = "#{SecureRandom.uuid}.txt"

  htmlContent = premailer.to_inline_css
  txtContent = premailer.to_plain_text
  redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT, :db => REDIS_DB)
  redis.setex(htmlFilename, REDIS_HTML_EXPIRY, htmlContent)
  redis.setex(txtFilename, REDIS_txt_EXPIRY, txtContent)

  htmlPath = "html/#{htmlFilename}"
  txtPath = "txt/#{txtFilename}"
  status 201
  content_type :json
  { 
    :options => premailer_opts,
    :documents => 
      {
        :html => "#{url(htmlPath)}",
        :txt => "#{url(txtPath)}" 
      } 
  }.to_json
end

get '/html/:filename' do |filename|
  redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT, :db => REDIS_DB)
  content = redis.get(filename)

  if content.nil?
    status 404
  else
    content
  end
end


error do
  logger.error env['sinatra.error'].message
  status 500
end
