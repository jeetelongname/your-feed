# lib/article_management.rb

# frozen_string_literal: true

require 'digest'

module YourFeed
  # Article insertion and retrival
  module ArticleManagement
    # @param db [Db] the db object
    # @param article [String] an article url
    # @param user_token [String] the users session token
    # @return [Nil]
    def insert_article(db, article, user_token)
      db.get_user(user_token) => { user_id: }

      link_hash = Digest::MD5.digest article

      if db.article_exists?(link_hash)
        return {
          err: 'You have already added this article'
        }
      end

      db.insert_article link_hash, article, user_id
    end
  end
end
