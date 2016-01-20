require 'sinatra'
require 'sinatra/streaming'
require 'premailer'
require 'json'

configure do
  set :environment, 'production'
end
def handleRequest(params)
  url = params['url']
  html = params['html']
  
  if url.nil?
    premailer = Premailer.new(html, :with_html_string => true)
  else
    premailer = Premailer.new(url)
  end
  
  htmlContent = premailer.to_inline_css

  content_type :json
  { :html => "#{htmlContent}"} .to_json
end

get '/test/' do
  "this is your rack app"
end
get '/sinatra/test/' do
  "this is your rack app with prefix"
end

post '/api/0.1/documents' do
  handleRequest params
end

get '/api/0.1/documents' do
  handleRequest params
end


error do
  logger.error env['sinatra.error'].message
  status 500
end
