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

before '/entities/*' do
  content_type :json
end

#Index
get '/?' do 
  @entities = Entity.desc(:created_at)
  erb :index 
end

get '/nosku' do 
  @entities = Entity.desc(:created_at)
  erb :nosku
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

helpers do 

  def currency(pennies)
    sprintf "%.2f", pennies.to_f / 100
  end
end
