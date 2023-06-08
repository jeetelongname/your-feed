# lib/db.rb

require 'sqlite3'

module YourFeed
  # all of the database things
  class Db
    attr_reader :db

    # set up the db.
    def initialize
      @db = SQLite3::Database.new ENV['DATABASE_URL']

      # user table
      @db.execute <<-SQL
      create table if not exists user (
        user_id integer primary key autoincrement,
        username text unique not null,
        password_hash text not null,
        session_token text unique,
        date_added timestamp default current_timestamp
      );
      SQL

      # article table
      @db.execute <<-SQL
      create table if not exists article (
        link_hash text primary key,
        url text not null
      );
      SQL

      # link table table
      @db.execute <<-SQL
        create table if not exists user_article (
          user_id integer not null references user(user_id),
          link_hash text not null references article(link_hash),
          date_added timestamp default current_timestamp,
          primary key (user_id, link_hash)
        );
      SQL
    end

    def insert_user(*args)
      @db.execute(
        'insert into user (username, password_hash, session_token) values ( ?, ?, ? );',
        args
      )
    end

    def get_user_from_token(token)
      @db.execute(
        'select username from user where session_token = ?',
        token
      ).first.first
    end

    def get_passhash(username)
      @db.execute(
        'select password_hash from user where username = ?',
        username
      ).first.first
    end

    def set_session_token(username, session_token)
      @db.execute(
        'update user set session_token = ? where username = ?;',
        session_token,
        username
      )
    end

    def username_exists?(name)
      result = @db.execute('select * from user where username = ?;', name)

      !result.empty?
    end

    # should be called before the program finishes.
    def finalize
      @db.close
    end
  end
end
