# frozen_string_literal: true

require 'your_feed/version'
require 'your_feed/db'
require 'your_feed/user_management'
require 'your_feed/article_management'

require 'sinatra/base'

module YourFeed
  # the app, the entry point, the whole shebang
  class App < Sinatra::Base
    # setup
    enable :sessions
    db = Db.new
    helpers UserManagement, ArticleManagement

    # routes
    get '/' do
      if (token = session[:token])
        db.get_user(token) => { username:, **}
        erb :indexloggedin, locals: { username:, error: params['error'] }
      else
        erb :index
      end
    end

    get '/login' do
      erb :login, locals: { error: params['error'] }
    end

    get '/articles' do
      if (token = session[:token])
        links = db.get_articles(token)
        erb :links, locals: { links: }
      else
        redirect '/login?error=You need to be logged in'
      end
    end

    post '/login' do
      response = login db, params['username'], params['password']

      case response
      in { err: }
        redirect "/login?error=#{err}"
      in session_token
        session[:token] = session_token
      end
      redirect '/'
    end

    post '/register' do
      response = register db, params['username'], params['password']

      case response
      in { err: }
        redirect "/login?error=#{err}"
      in session_token
        session[:token] = session_token
      end

      redirect '/'
    end

    post '/logout' do
      session.delete(:token)
      redirect '/'
    end

    post '/submit' do
      response = insert_article(db, params['article'], session[:token])
      case response
      in { err: }
        redirect "/?error=#{err}"
      else
        redirect '/'
      end
    end
  end
end
