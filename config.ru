require 'rubygems'
require 'bundler'

Bundler.require

require './app.rb'
run Sinatra::Application
set :views, "#{File.dirname(__FILE__)}/views"