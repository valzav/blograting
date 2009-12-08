require 'rubygems'
require 'compass'
require 'sinatra'
require 'haml'
require 'sequel'
require 'logger'
require 'rutils'

configure do
  set :clean_trace, true
  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir = 'views'
  end
  set :haml, { :format => :html5 }
  set :sass, Compass.sass_engine_options
end

configure :production do
  puts "production environment"
  DB = Sequel.connect('mysql://root:@localhost/blogovod_prod')
end

configure :development do
  puts "development environment"
  DB = Sequel.connect('mysql://root:@localhost/blogovod_dev')
  #DB.loggers << Logger.new($stdout)
end

configure :test do
  puts "test environment"
  set :show_exceptions, false
  set :dump_errors, true
  set :raise_errors, true
  DB = Sequel.connect('mysql://root:@localhost/blogovod_test')
  #DB.loggers << Logger.new($stdout)
end

helpers do
  def partial(page, options={})
    haml page, options.merge!(:layout => false)
  end
  def link_to(text,link)
    if text.nil? || text.empty?
      %{<a href="#{link}">#{link}</a>}
    else
      %{<a href="#{link}">#{text}</a>}
    end
  end
  def display_post_date(date)
    diff = Time.now.to_i - date.to_i
    if diff < 0 || diff > 3600*24*7
      date.strftime("%d.%m.%Y")
    else
      RuTils::DateTime.distance_of_time_in_words(date.to_i,Time.now.to_i) + " назад"
    end
  end
end

Dir.glob('models/*.rb').each {|f| require f }

error do
end

not_found do
end

#get '/main.css' do
#  content_type 'text/css', :charset => 'utf-8'
#  File.read('views/main.sass')
#end

get '/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass params[:name].to_sym, Compass.sass_engine_options
end

get '/' do
  @posts = Top.global.posts
  haml :index, :layout => :application
end
