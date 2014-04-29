require 'rubygems'
require 'bundler'

ENV['RACK_ENV'] ||= 'development'

Bundler.require(:default)

class Entity
  include Mongoid::Document
  include Mongoid::Timestamps

  field :purchase_id,  type: String
  field :account_id,   type: String
  field :user_id,      type: String
  field :name,         type: String
  field :sku,          type: String
  field :cash_price,   type: Integer, :default => 0
  field :credit_price, type: Integer, :default => 0
  field :quantity,     type: Integer, :default => 0
  field :notes,        type: String
  field :processed,    type: Boolean, :default => false
  field :ratio,        type: Float, :default => 1
  
  def subtotal_cash
    cash_price * quantity
  end
  
  def subtotal_credit
    credit_price * quantity
  end
  
  def cash
    (subtotal_cash * (1 - ratio)).round.to_i
  end
  
  def credit
    (subtotal_credit * ratio).round.to_i
  end
end

configure do
  set :root,    File.dirname(__FILE__)
  
  Mongoid.load!(File.dirname(__FILE__) + '/mongoid.yml')
end

helpers do
  def currency(pennies)
    sprintf "%.2f", pennies.to_f / 100
  end
end

before '/entities/*' do
  content_type :json
end

#Index
get '/?' do 
  @purchases = Entity.desc(:created_at).group_by(&:purchase_id)
  erb :index 
end

# Print
get '/print/:id/?' do 
  @entity = Entity.find(params[:id])
  @data = {
    :name => @entity.name,
    :sku  => @entity.sku,
    :cash_price => @entity.cash_price,
    :credit_price => @entity.credit_price,
    :purchase_id => @entity.purchase_id
  }.to_json
  
  if params[:print]
    erb :printer, :layout => false
  else
    erb :show
  end
end

get '/remove/:id' do
  @entity = Entity.find(params[:id])
  @entity.destroy
  redirect '/'
end

# API Index
get '/entities/:account_id/?' do
  Entity.where(:account_id => params[:account_id]).to_json
end

# API Find
get '/entities/:id/?' do
  begin
    Entity.find(params[:id]).to_json
  rescue
    status 404
  end
end

# API Create
post '/entities/?' do
  Entity.create(JSON.parse(request.body.read))
  status 201
end

# API Update
put '/entities/:account_id/:id/?' do
  begin
    Entity.find(params[:id]).update_attributes(JSON.parse(request.body.read))
  rescue
    status 404
  end
end

# API Destroy
delete '/entities/:id' do
  begin
    Entity.find(params[:id]).destroy
  rescue
    status 404
  end
end

not_found do
  status 404
  ""
end
