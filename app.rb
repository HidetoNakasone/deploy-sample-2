
require "bundler/setup"
Bundler.require

if development?
  require 'sinatra/reloader'
end

enable :sessions

def db
  @db ||= PG.connect(
    dbname: 'heroku_deploy_sample_2'
  )
end

def signin_check()
  redirect '/signin' if session[:user_id].nil?
end

get '/' do
  signin_check()

  @res = db.exec_params('select * from todos where creater_id = $1 order by id asc', [session[:user_id]])

  erb :top
end

get '/signin' do
  erb :signin
end

post '/signin' do
  res = db.exec_params('select id from users where name = $1 and pass = $2;', [params[:name], params[:pass]]).first
  redirect '/signin' if res.nil?
  session[:user_id] = res['id'].to_i
  session[:user_name] = params[:name]

  redirect '/'
end

get '/signup' do
  erb :signup
end

post '/signup' do
  res = db.exec_params('select id from users where name = $1 and pass = $2;', [params[:name], params[:pass]]).first
  redirect '/signin' unless res.nil?

  session[:user_id] = db.exec_params('insert into users(name, pass) values($1, $2) returning id;', [params[:name], params[:pass]]).first['id'].to_i
  session[:user_name] = params[:name]

  redirect '/'
end

post '/new' do
  signin_check()
  status = true if params[:status] == "true"
  status = false if params[:status] == "false"
  db.exec_params('insert into todos(creater_id, title, status) values($1, $2, $3)', [session[:user_id], params[:title], status])
  redirect '/'
end

get '/edit/:id' do
  signin_check()

  @res = db.exec_params('select * from todos where id = $1', [params[:id].to_i]).first

  redirect '/' unless @res['creater_id'].to_i == session[:user_id]
  erb :edit
end

post '/edit' do
  signin_check()
  db.exec_params('update todos set title = $1, status = $2 where id = $3', [params[:title], params[:status], params[:id].to_i])
  redirect '/'
end

get '/delete/:id' do
  signin_check()

  creater_id = db.exec_params('select creater_id from todos where id = $1', [params[:id].to_i]).first['creater_id'].to_i
  redirect '/' unless creater_id == session[:user_id]

  db.exec_params('delete from todos where id = $1', [params[:id].to_i])
  redirect '/'
end
