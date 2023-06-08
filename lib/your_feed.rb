# frozen_string_literal: true

require 'your_feed/version'
require 'your_feed/db'
require 'your_feed/user_management'

require 'sinatra/base'

module YourFeed
  # the app, the entry point, the whole shebang
  class App < Sinatra::Base
    # setup
    enable :sessions

    db = Db.new
    helpers UserManagement

    # routes
    get '/' do
      if session[:token]
        puts :inside
        username = db.get_user_from_token(session[:token])
        erb :indexloggedin, locals: { username: }
      else
        erb :index, locals: { error: params['error'] }
      end
    end

    post '/login' do
      response = login db, params['username'], params['password']

      case response
      in { err: }
        redirect "/?error=#{err}"
      in session_token
        session[:token] = session_token
      end
      redirect '/'
    end

    post '/register' do
      response = register db, params['username'], params['password']

      case response
      in { err: }
        redirect "/?error=#{err}"
      in session_token
        session[:token] = session_token
      end

      redirect '/'
    end

    post '/logout' do
      session.delete(:token)
      redirect '/'
    end
  end
end
