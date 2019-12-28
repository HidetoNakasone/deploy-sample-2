
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
  redirect '/hello' if session[:user_id].nil?
end

get '/' do
  signin_check()

  @res = db.exec_params('select * from todos where creater_id = $1 order by status asc, id asc', [session[:user_id]])

  erb :top
end

get '/hello' do
  erb :hello
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
  # 既存のアカウントとして、その名前が使われていたら駄目！ってことにする。
  res = db.exec_params('select id from users where name = $1;', [params[:name]]).first
  redirect '/signin' unless res.nil?

  session[:user_id] = db.exec_params('insert into users(name, pass) values($1, $2) returning id;', [params[:name], params[:pass]]).first['id'].to_i
  session[:user_name] = params[:name]

  redirect '/'
end

get '/signout' do
  session[:user_id] = nil
  session[:user_name] = nil
  redirect '/'
end

get '/new' do
  signin_check()
  db.exec_params('insert into todos(creater_id, title, status) values($1, $2, $3)', [session[:user_id], params[:title], false])
  'ok'.to_json
end

get '/edit' do
  signin_check()
  p params
  db.exec_params('update todos set title = $1 where id = $2', [params[:title], params[:id].to_i])
  'ok'.to_json
end

get '/check_edit' do
  signin_check()

  target_id = params[:id].to_i
  res = db.exec_params('select * from todos where id = $1', [target_id]).first

  unless (res.nil?) and (res['id'] == session[:user_id])
    if res['status'] == 't'
      db.exec_params('update todos set status = $1 where id = $2', [false, target_id])
    else
      db.exec_params('update todos set status = $1 where id = $2', [true, target_id])
    end
  end
  redirect '/'
end

get '/delete/:id' do
  signin_check()

  creater_id = db.exec_params('select creater_id from todos where id = $1', [params[:id].to_i]).first['creater_id'].to_i
  redirect '/' unless creater_id == session[:user_id]

  db.exec_params('delete from todos where id = $1', [params[:id].to_i])
  redirect '/'
end

post '/icon_image' do
  signin_check()
  FileUtils.mv(params[:up_image][:tempfile], "./public/images/user_icon/#{session[:user_id].to_s}.jpg")
  'ok'.to_json
end
