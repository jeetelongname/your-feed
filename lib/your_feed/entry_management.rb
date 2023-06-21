# lib/entry_management.rb

module YourFeed
  # A single entry object
  class Entry
    attr_reader :link, :is_read, :date, :weight

    def initialize(*args)
      @link, @is_read, @date = args
      @weight = 0
    end

    def calculate_weight; end

    # @return [String]
    def inspect
      "Entry(@link: #{@link}, @is_read: #{@is_read}, @date: #{@date}, @weight: #{@weight})<br>"
    end

    def to_s; end
  end

  # The Entry and atom feed lifecycle
  module EntryManagement
    # @param db [Db]
    # @param username [String]
    # @return [String]
    def return_feed(db, username)
      # TODO: actual error response!
      return "miss!\n" unless db.username_exists? username

      articles = db.get_articles_feed(username:).map { Entry.new(*_1) }

      articles.map(&:inspect).reduce(&:<<)
    end
  end
end
