require 'rubygems'
require 'bundler'

ENV['RACK_ENV'] ||= 'development'

Bundler.require(:default)

class Qrcode
  include Mongoid::Document
  include Mongoid::Timestamps

  field :purchase_id,  type: String
  field :account_id,   type: String
  field :user_id,      type: String
  field :name,         type: String
  field :sku,          type: String
  field :cash_price,   type: Integer
  field :credit_price, type: Integer
  field :quantity,     type: Integer
  field :notes,        type: String
  field :processed,    type: Boolean
  field :ratio,        type: Float
end

configure do
  set :root,    File.dirname(__FILE__)
  
  Mongoid.load!(File.dirname(__FILE__) + '/mongoid.yml')
end

before '/qrcodes/*' do
  content_type :json
end

#Index
get '/?' do 
  @qrcodes = Qrcode.desc(:created_at)
  erb :index 
end

get '/nosku' do 
  @qrcodes = Qrcode.desc(:created_at)
  erb :nosku
end

# Print
get '/print/:id/?' do 
  @qrcode = Qrcode.find(params[:id])
  @data = {
    :name => @qrcode.name,
    :sku  => @qrcode.sku,
    :cash_price => @qrcode.cash_price,
    :credit_price => @qrcode.credit_price,
    :purchase_id => @qrcode.purchase_id
  }.to_json
  
  if params[:print]
    erb :printer, :layout => false
  else
    erb :show
  end
end

get '/remove/:id' do
  @qrcode = Qrcode.find(params[:id])
  @qrcode.destroy
  redirect '/'
end

# API Index
get '/qrcodes/:account_id/?' do
  Qrcode.where(:account_id => params[:account_id]).to_json
end

# API Find
get '/qrcodes/:id/?' do
  begin
    Qrcode.find(params[:id]).to_json
  rescue
    status 404
  end
end

# API Create
post '/qrcodes/?' do
  Qrcode.create(JSON.parse(request.body.read))
  status 201
end

# API Update
put '/qrcodes/:account_id/:id/?' do
  begin
    Qrcode.find(params[:id]).update_attributes(JSON.parse(request.body.read))
  rescue
    status 404
  end
end

# API Destroy
delete '/qrcodes/:id' do
  begin
    Qrcode.find(params[:id]).destroy
  rescue
    status 404
  end
end

not_found do
  status 404
  ""
end

helpers do 

  def currency(pennies)
    sprintf "%.2f", pennies.to_f / 100
  end
end