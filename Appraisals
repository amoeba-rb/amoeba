appraise 'activerecord-3.2' do
  gem 'activerecord', '~> 3.2.0'
end

appraise 'activerecord-4.0' do
  gem 'activerecord', '~> 4.0.0'
end

appraise 'activerecord-4.1' do
  gem 'activerecord', '~> 4.1.0'
end

appraise 'activerecord-4.2' do
  gem 'activerecord', '~> 4.2.0'
end

appraise 'activerecord-head' do
  git 'git://github.com/rails/arel.git' do
    gem 'arel'
  end
  git 'git://github.com/rails/rails.git' do
    gem 'activerecord'
  end
end
