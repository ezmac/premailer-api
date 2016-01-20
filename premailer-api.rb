require 'sinatra'
require 'sinatra/streaming'
require 'premailer'
require 'json'
require 'pry'

configure do
  set :environment, 'production'
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

post '/api/premailer/0.1/documents' do
  if request.env['CONTENT_TYPE'] == 'application/json'
    requestBody = request.body.read
    if not requestBody.empty?
      body = JSON.parse requestBody
      html = body['html']
      url = body['url']
    else
      #LIAR!
      return "if you're going to send a content_type of 'application/json' send a body"
    end
  else
    html = params['html']
    url = params['url']
  end
  if url.nil?
    premailer = Premailer.new(html, :with_html_string => true)
  else
    premailer = Premailer.new(url)
  end
  htmlContent = premailer.to_inline_css
  htmlContent = premailer.to_inline_css

  respondWith htmlContent
end

get '/api/premailer/0.1/documents' do
  url = params['url']
  premailer = Premailer.new(url)
  htmlContent = premailer.to_inline_css

  respondWith htmlContent
end


error do
  logger.error env['sinatra.error'].message
  status 500
end
