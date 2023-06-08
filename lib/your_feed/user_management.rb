# lib/user_management.rb
require 'bcrypt'
require 'securerandom'

module YourFeed
  # all user management code here
  module UserManagement
    def generate_token
      SecureRandom.bytes(32).to_s
    end

    # Register a first time user, return a session token.
    def register(db, username, password)
      return { err: "Username or Password can't be empty" } if username.empty? || password.empty?

      return { err: 'Username Exists' } if db.username_exists?(username)

      pass_hash = BCrypt::Password.create(password)
      session_token = generate_token

      db.insert_user(
        username,
        pass_hash.to_s,
        session_token
      )

      session_token
    end

    # log a user in
    def login(db, username, password)
      return { err: "Username or Password can't be empty" } if username.empty? || password.empty?

      return { err: 'Username does not exist' } unless db.username_exists?(username)

      passhash = BCrypt::Password.new db.get_passhash(username)
      return { err: 'Incorrect Password' } unless passhash == password

      session_token = generate_token
      db.set_session_token(username, session_token)

      session_token
    end
  end
end
