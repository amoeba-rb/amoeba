# frozen_string_literal: true

appraise 'activerecord-6.0' do
  gem 'activerecord', '~> 6.0.0'
  group :development, :test do
    gem 'sqlite3', '~> 1.6.0'
  end
end

appraise 'activerecord-6.1' do
  gem 'activerecord', '~> 6.1.0'
  group :development, :test do
    gem 'sqlite3', '~> 1.6.0'
  end
end

appraise 'activerecord-7.0' do
  gem 'activerecord', '~> 7.0.0'
  group :development, :test do
    gem 'sqlite3', '~> 1.6.0'
  end
end

appraise 'jruby-activerecord-7.0' do
  gem 'activerecord', '~> 7.0.0'
  group :development, :test do
    gem 'activerecord-jdbc-adapter', '~> 70.1'
    gem 'activerecord-jdbcsqlite3-adapter', '~> 70.1'
  end
end

appraise 'activerecord-head' do
  git 'https://github.com/rails/rails.git', branch: 'main' do
    gem 'activerecord'
  end
  group :development, :test do
    gem 'sqlite3', '~> 1.6.0'
  end
end

appraise 'jruby-activerecord-head' do
  git 'https://github.com/rails/rails.git', branch: 'main' do
    gem 'activerecord'
  end
  group :development, :test do
    git 'https://github.com/jruby/activerecord-jdbc-adapter' do
      gem 'activerecord-jdbc-adapter'
      gem 'activerecord-jdbcsqlite3-adapter',
          glob: 'activerecord-jdbcsqlite3-adapter/activerecord-jdbcsqlite3-adapter.gemspec'
    end
  end
end
