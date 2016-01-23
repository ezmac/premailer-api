require 'rubygems'
require 'bundler'
Bundler.require
require 'sinatra'

require File.expand_path File.dirname(__FILE__)+'/premailer-api.rb'

run Sinatra::Application
