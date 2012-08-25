require "sinatra"
require "instagram"

enable :sessions

#live
CALLBACK_URL = "http://limitless-beyond-2035.herokuapp.com/oauth/callback"
#dev
#CALLBACK_URL = "http://0.0.0.0:4567/oauth/callback"

Instagram.configure do |config|
  #live
  config.client_id = "01821786b2694a6babdbe8d57f0e22bf"
  config.client_secret = "11c3deaa08404d1791b909896d4c7027"
  #dev
  #config.client_id = "7fc7b7b6c6964427800ef5dbecc58582"
  #config.client_secret = "8286ed2ce28d4f3b98e0768e855e510c"

end

get "/" do
  @signin = '<a href="/oauth/connect" class="signin"></a>'
  erb :signin
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/mosaic"
end

get "/mosaic" do

  client = Instagram.client(:access_token => session[:access_token])
  
  @html = ''
  @userpic = client.user.profile_picture
  @randColor = '%06x' % (rand * 0xffffff)

  media = client.user_media_feed
  imgs = Array.new
  
  #get media images and store them in an array to be randomized for display
  for m in media.data
   imgs.push(m.images.thumbnail.url)
  end

  #create random 'mosaic' pattern
  2500.times do
    r = Random.new
    @html << "<img src=\"#{imgs[r.rand(0..(imgs.size-1))]}\" alt=\"\" class=\"thumbnail\" />"
  end
  
  erb :mosaic
end