require 'rubygems'
require 'bundler'
require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

ENV['RACK_ENV'] ||= 'development'

Bundler.require(:default)

class Qrcode
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name,         type: String
  field :sku,          type: String
  field :cash_price,   type: Integer
  field :credit_price, type: Integer
  field :quantity,     type: Integer
  field :purchase_id,  type: String
  field :account_id,   type: String
  field :notes,        type: String
  field :user,         type: String
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
  @qr = RQRCode::QRCode.new( @data, :size => 8, :level => :l )
  @barcode = Barby::PngOutputter.new(@qrcode).to_png
  File.open('@qrcode.png', 'w'){|f| f.write @barcode}
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
get '/qrcodes/?' do
  Qrcode.all.to_json
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
put '/qrcodes/:id/?' do
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

def pennies_to_decimal(pennies)
  pennies.to_f / 100
end

def currency(pennies, options={})
  number_to_currency(pennies_to_decimal(pennies), options)
end