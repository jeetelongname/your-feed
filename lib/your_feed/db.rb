# lib/db.rb

require 'sqlite3'

module YourFeed
  # all of the database things
  class Db
    # The underlying database connection
    # @return [Sqlite3::Database]
    attr_reader :db

    # set up the db.
    def initialize
      @db = SQLite3::Database.new ENV['DATABASE_URL']

      @db.execute_batch <<-SQL
      create table if not exists user (
        user_id integer primary key autoincrement,
        username text unique not null,
        password_hash text not null,
        session_token text unique,
        date_added timestamp default current_timestamp
      );

      create table if not exists article (
        link_hash text primary key,
        url text not null
      );

      create table if not exists user_article (
        user_id integer not null references user(user_id),
        link_hash text not null references article(link_hash),
        date_added timestamp default current_timestamp,
        primary key (user_id, link_hash)
      );
      SQL
    end

    # @param token [String] A session token
    # @return [Hash{Symbol => String}] a single result line
    def get_user(token)
      result = @db.query(
        'select user_id, username, password_hash, date_added from user where session_token = ?',
        token
      )
      result_hash = result.next_hash
      result.close
      # HACK: I just want a hash man
      result_hash.to_h.map { [_1.to_sym, _2] }.to_h
    end

    # @param username [String]
    # @return [String]
    def get_passhash(username)
      @db.execute(
        'select password_hash from user where username = ?',
        username
      ).first.first
    end

    # get articles
    # @param token [String] the users token
    # @return [Array<String>] the list of urls
    def get_articles(token)
      query =  <<-SQL
        select a.url
        from ((article a
        join user_article on a.link_hash = user_article.link_hash)
        join user on user.user_id = user_article.user_id)
        where user.session_token = ?;
      SQL

      @db.execute(query, token).map(&:first)
    end

    # @param name [String] username
    # @return [Boolean]
    def username_exists?(name)
      result = @db.execute('select * from user where username = ?;', name)
      !result.empty?
    end

    # @param link_hash [String] a hashed url
    # @return [Boolean]
    def article_exists?(link_hash)
      result = @db.execute(
        'select * from article where link_hash = ?',
        link_hash
      )

      !result.empty?
    end

    # @param args [String, String, String]  username, password, session token
    # @return [nil]
    def insert_user(*args)
      @db.execute(
        'insert into user (username, password_hash, session_token) values ( ?, ?, ? );',
        args
      )
    end

    # @param link_hash [String] a hashed link url
    # @param url [String] the unhashed link url
    # @param user_id [FixNum] the id of a user
    # @return [nil]
    def insert_article(link_hash, url, user_id)
      @db.execute(
        'insert into article (link_hash, url) values (?, ?);',
        link_hash,
        url
      )
      @db.execute(
        'insert into user_article (user_id, link_hash) values (?, ?);',
        user_id,
        link_hash
      )
    end

    # @param username [String] a users username
    # @param session_token [String] a new session token
    # @return [nil]
    def set_session_token(username, session_token)
      @db.execute(
        'update user set session_token = ? where username = ?;',
        session_token,
        username
      )
    end

    # should be called before the program finishes.
    # @return [nil]
    def finalize
      @db.close
    end
  end
end
