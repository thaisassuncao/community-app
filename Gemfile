# frozen_string_literal: true

source "https://rubygems.org"
ruby "3.3.9"

gem "pg", "~> 1.5"
gem "puma", ">= 6.4"
gem "rails", "7.2.2.2"

group :development, :test do
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

group :test do
  gem "database_cleaner-active_record"
  gem "shoulda-matchers"
end
