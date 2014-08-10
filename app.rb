require "sinatra"
require "instagram"

enable :sessions

configure :production do
  CALLBACK_URL = "http://instamosaic.herokuapp.com/oauth/callback"
end

configure :development, :test do
  require 'dotenv'
  Dotenv.load
  CALLBACK_URL = "http://0.0.0.0:4567/oauth/callback"
end

Instagram.configure do |config|
  config.client_id = ENV['CLIENT_ID']
  config.client_secret = ENV['CLIENT_SECRET']
end

get "/" do
  @signin = '<a href="/oauth/connect" class="signin"></a>'
  erb :signin
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code],
                                        :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/mosaic"
end

get "/mosaic" do

  client = Instagram.client(:access_token => session[:access_token])

  @html = ''
  @userpic = client.user.profile_picture
  @randColor = '%06x' % (rand * 0xffffff)

  media = client.user_media_feed
  imgs = media.data.collect { |m| m.images.thumbnail.url }

  #create random 'mosaic' pattern
  2500.times do
    r = Random.new
    @html << "<img src=\"#{imgs[r.rand(0..(imgs.size-1))]}\" class=\"thumbnail\" />"
  end

  erb :mosaic
end
