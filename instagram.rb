require "sinatra"
require "instagram"

enable :sessions

CALLBACK_URL = "http://limitless-beyond-2035.herokuapp.com/oauth/callback"

Instagram.configure do |config|

  config.client_id = "XXXXXXXXXXXXXXXXXXXXXXXX"
  config.client_secret = "XXXXXXXXXXXXXXXXXXXXXXXX"

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