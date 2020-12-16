appraise 'activerecord-4.2' do
  gem 'activerecord', '~> 4.2.0'
  group :development, :test do
    gem "sqlite3", "~> 1.3.0"
  end
end

appraise 'activerecord-5.0' do
  gem 'activerecord', '~> 5.0.0'
  group :development, :test do
    gem "sqlite3", "~> 1.3.0"
  end
end

appraise 'activerecord-5.1' do
  gem 'activerecord', '~> 5.1.0'
  group :development, :test do
    gem "sqlite3", "~> 1.3.0"
  end
end

appraise 'activerecord-5.2' do
  gem 'activerecord', '~> 5.2.0'
  group :development, :test do
    gem "sqlite3", "~> 1.3.0"
  end
end

appraise 'activerecord-6.0' do
  gem 'activerecord', '~> 6.0.0'
  group :development, :test do
    gem "sqlite3", "~> 1.4.0"
  end
end

appraise 'activerecord-6.1' do
  gem 'activerecord', '~> 6.1.0'
  group :development, :test do
    gem "sqlite3", "~> 1.4.0"
  end
end

appraise 'activerecord-head' do
  git 'git://github.com/rails/arel.git' do
    gem 'arel'
  end
  git 'git://github.com/rails/rails.git' do
    gem 'activerecord'
  end
  group :development, :test do
    gem "sqlite3", "~> 1.4.0"
  end
end
