# frozen_string_literal: true

require_relative 'lib/your_feed/version'

Gem::Specification.new do |spec|
  spec.name = 'your_feed'
  spec.version = YourFeed::VERSION
  spec.authors = ['Jeetaditya Chatterjee']
  spec.email = ['jeetelongname@gmail.com']

  spec.summary = 'A web app to aggretate articles to then read in your rss feed reader'
  # spec.description = 'TODO: Write a longer description or delete this line.'
  spec.homepage = 'https://github.com/jeetelongname/your_feed'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  # spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/jeetelongname/your_feed'
  spec.metadata['changelog_uri'] = 'https://github.com/jeetelongname/your_feed/blob/senpai/changelog.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bcrypt', '~> 3.1'
  spec.add_dependency 'puma', '~> 6.3'
  spec.add_dependency 'rackup', '~> 1.0'
  spec.add_dependency 'sinatra', '~> 3.0'
  spec.add_dependency 'sqlite3', '~> 1.6'

  spec.add_development_dependency 'irb', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'solargraph', '~> 0.49.0'
  spec.add_development_dependency 'yard', '~> 0.9.34'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
