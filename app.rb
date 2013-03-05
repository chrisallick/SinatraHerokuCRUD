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
    $redis.smembers("messages").each do |id|
        messages.push( $redis.hgetall("message:#{id}") )
    end

    { :result => "success", :messages => messages }.to_json
end

post '/message' do
    content_type :json
    
    message = params[:message]
    if message  
        id = $redis.incr(:sequence_counter)
        time = Time.now
        time = time.strftime("%B %d, %Y")
        
        $redis.hmset("message:#{id}", "message", message, "time", time, "id", id )
        $redis.sadd("messages", id)
        
        { :result => "success", :id => id }.to_json
    else
        { :result => "fail", :error => "invalid params" }.to_json
    end
end