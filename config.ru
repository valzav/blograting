require 'app'

#use Rack::Session::Cookie, :key => '_blogovod_ru', :domain => '.blogovod.ru'

if ENV['RACK_ENV'] == 'production'
  log = File.new("log/production.log", "a+")
  STDOUT.reopen(log)
  STDERR.reopen(log)
end

run Sinatra::Application
