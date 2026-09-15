# frozen_string_literal: true

appraise 'activerecord-8.0' do
  gem 'activerecord', '~> 8.0.0'
end

appraise 'activerecord-7.2' do
  gem 'activerecord', '~> 7.2'
end

appraise 'activerecord-8.1' do
  gem 'activerecord', '~> 8.1.0'
end

appraise 'jruby-activerecord-7.1' do
  gem 'activerecord', '~> 7.1.0'
  group :development, :test do
    gem 'activerecord-jdbc-adapter', '~> 71.0'
    gem 'activerecord-jdbcsqlite3-adapter', '~> 71.0'
  end
end

appraise 'jruby-activerecord-7.2' do
  gem 'activerecord', '~> 7.2.0'
  group :development, :test do
    gem 'activerecord-jdbc-adapter', '~> 72.0'
    gem 'activerecord-jdbcsqlite3-adapter', '~> 72.0'
  end
end

appraise 'jruby-activerecord-8.0' do
  gem 'activerecord', '~> 8.0.0'
  group :development, :test do
    gem 'activerecord-jdbc-adapter', '~> 80.0.pre1'
    gem 'activerecord-jdbcsqlite3-adapter', '~> 80.0.pre1'
  end
end

appraise 'activerecord-head' do
  git 'https://github.com/rails/rails.git', branch: 'main' do
    gem 'activerecord'
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
