require 'rubygems'
require 'bundler'

ENV['RACK_ENV'] ||= 'development'

Bundler.require(:default)

class Qrcode
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name,  type: String
  field :sku,   type: String
end

configure do
  set :root,    File.dirname(__FILE__)
  
  Mongoid.load!(File.dirname(__FILE__) + '/mongoid.yml')
end

before '/qrcodes/*' do
  content_type :json
end

get '/?' do 
  @codes = Qrcode.all
  erb :index 
end

# Index
get '/qrcodes/?' do
  Qrcoder.all.to_json
end

# Find
get '/qrcodes/:id/?' do
  begin
    Qrcoder.find(params[:id]).to_json
  rescue
    status 404
  end
end

# Create
post '/qrcodes/?' do
  Qrcoder.create(JSON.parse(request.body.read))
  status 201
end

# Update
put '/qrcodes/:id/?' do
  begin
    Qrcoder.find(params[:id]).update_attributes(JSON.parse(request.body.read))
  rescue
    status 404
  end
end

# Destroy
delete '/Qrcodes/:id' do
  begin
    Qrcoder.find(params[:id]).destroy
  rescue
    status 404
  end
end

not_found do
  status 404
  ""
end