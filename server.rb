require 'sinatra/base'
require 'erb'

require 'rubygems'
require 'data_mapper'

require 'date'
require 'pg'

require 'yaml'

require './model/conversion'


# Setup DB
RACK_ENV = ENV['RACK_ENV'] || "development"
database = YAML.load_file(File.join('config', 'database.yml'))[RACK_ENV]
PG_HOST = database['host']
PG_PORT = database['port']
PG_USERNAME = database['username']
PG_PASSWORD = database['password']
PG_DATABASE = database['database']


module AffiliateTracking
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))

    set :views,  "#{dir}/views"
    set :public_folder, "#{dir}/public"
    set :static, true


    configure :development do
      DataMapper.setup(:default, "postgres://#{PG_USERNAME}:#{PG_PASSWORD}@#{PG_HOST}/#{PG_DATABASE}")
      DataMapper::Logger.new(STDOUT, :debug)
      DataMapper::Model.raise_on_save_failure = true

      #DataMapper.auto_migrate!
      DataMapper.finalize
    end

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html

      def current_section
        url_path request.path_info.sub('/','').split('/')[0].downcase
      end

      def current_page
        url_path request.path_info.sub('/','')
      end

      def url_path(*path_parts)
        [ path_prefix, path_parts ].join("/").squeeze('/')
      end
      alias_method :u, :url_path

      def path_prefix
        request.env['SCRIPT_NAME']
      end

      def class_if_current(path = '')
        'class="current"' if current_page[0, path.size] == path
      end

      def tab(name)
        dname = name.to_s.downcase
        path = url_path(dname)
        "<li #{class_if_current(path)}><a href='#{path}'>#{name}</a></li>"
      end

      def tabs
        AffiliateTracking::Server.tabs
      end

      def show_args(args)
        Array(args).map { |a| a.inspect }.join("\n")
      end

      def partial?
        @partial
      end

      def partial(template, local_vars = {})
        @partial = true
        erb(template.to_sym, {:layout => false}, local_vars)
      ensure
        @partial = false
      end

    end

    get '/pixel.png' do
      c = Conversion.create!(
      :referrer => request.referrer,
        :user_agent => request.user_agent,
        :cookies => request.cookies,
        :ip => request.ip,
        :created_at => Time.now
      )
      c.errors.each do |error|
        raise error.inspect
      end

      content_type 'image/png'
      File.read(File.join('public', '1x1.png'))
    end

    get '/overview' do
      @conversions_by_date = Conversion.by_date
      erb :overview
    end

    get '/details' do
      @conversions = Conversion.all(:order => [:created_at.desc])
      erb :details
    end

    get "/?" do
      redirect url_path(:overview)
    end

    def self.tabs
      @tabs ||= ["Overview", "Details"]
    end
  end
end
