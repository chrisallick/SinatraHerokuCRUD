require 'sinatra'
require 'sinatra/partial'
require 'sinatra/reloader' if development?
require 'redis'

configure do
    redisUri = ENV["REDISTOGO_URL"] || 'redis://localhost:6379'
    uri = URI.parse(redisUri) 
    $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

get '/' do
    $redis.set("dope", "nachos")
    erb :main, :locals => {
        :dump => $redis.get("dope")
    }
end

get '/messages' do
    content_type :json
    
    messages = []
    all = $redis.lrange("messages", 0, $redis.llen("messages"))
    all.each do |message|
        messages.push( message )
    end
    { :result => "success", :messages => messages }.to_json
end

post '/message' do
    message = params[:message]

    if message  
        $redis.lpush( "messages", message )
        { :result => "success" }.to_json
    else
        { :result => "fail", :msg => "invalid params" }.to_json
    end
end

# put '/message' do
#     message = params[:message]

#     if message
#         all = $redis.lrange("messages", 0, $redis.llen("messages"))
#         all.each do |_message|
#             if message == _message
#                 #_message = message
#             end
#         { :result => "success" }.to_json
#     else
#         { :result => "fail" }.to_json
#     end
# end

delete '/message' do
    message = params[:message]

    if message
        $redis.lrem("message",0,message)
        { :result => "success" }.to_json
    else
        { :result => "fail" }.to_json
    end
end
