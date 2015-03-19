require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'
require 'pry'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

  def signed_up?
    meetup_id = params["id"]
    user_id = current_user.id
    signups = Signup.joins(:user, :meetup)
    members = signups.where(meetup_id: meetup_id)
    members.any? {|member| member.user_id == user_id}
  end


def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

get '/' do
  @titles = Meetup.all
  erb :index
end

get '/new_meet' do
  erb :new_meet, locals: {message: params["message"] || ""}
end

post '/new_meet' do
  name = params["name"]
  location = params["location"]
  description = params["description"]
  Meetup.create!(meetup_name: name, meetup_description: description, meetup_location:location )
  redirect '/'
end

get '/meetup/:id' do
  id = params["id"]
  message = params["message"]
  info = Meetup.find(id)
  signups = Signup.joins(:user, :meetup)
  members = signups.where(meetup_id: id)
  Comment.joins(:user, :meetup)
  comments = Comment.where(meetup_id: id)
  erb :meetup_info, locals: {info: info, members: members, message: message, comments: comments}
end

post '/meetup/:id' do
  meetup_id = params["id"]
  user_id = current_user.id
  if signed_up? == true
    flash[:notice] = "You've already joined this group."
  else
      Signup.create!(user_id: user_id, meetup_id: meetup_id)
      flash[:notice] = "You successfully joined the group!"
  end

  redirect "/meetup/#{params["id"]}?message=#{flash[:notice]}"
end

 post '/leave_group/:id' do
   meetup_id = params["id"]
   user_id = current_user.id
   Signup.where(user_id: user_id).destroy_all
   flash[:notice] = "You left the group."
   redirect "/meetup/#{meetup_id}?message=#{flash[:notice]}"
 end

post '/new_comment/:id' do
  meetup_id = params["id"]
  user_id = current_user.id
  body = params["comment"]
  title = params["title"]
  Comment.create(user_id: user_id, meetup_id: meetup_id, body: body, title: title)
  flash[:notice] = "Comment posted!"
  redirect "/meetup/#{params["id"]}?message=#{flash[:notice]}"
end


get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end
