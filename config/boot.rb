ENV['RACK_ENV'] ||= 'development'

require 'rubygems'
require 'bundler'

Bundler.require :default, ENV['RACK_ENV'].to_sym

BASE_PATH = File.expand_path('../../', __FILE__)

