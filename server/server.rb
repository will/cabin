require 'sinatra'
require 'heroku'
require 'json'

module Cabin
  class Server < Sinatra::Application
    def app
      ENV['APP'] || 'will'
    end

    get '/' do
      @app = app
      erb :index
    end

    get '/logs', provides: 'text/event-stream' do
      stream(:keep_open) do |out|
        EM::PeriodicTimer.new(20) { out << "\0" }
        Heroku::Auth.client.read_logs(app, ['tail=1']) do |lines|
          lines.split(/\n/).each {|line| out << "data: #{line}\n\n" }
        end
      end
    end

    get '/ps' do
      JSON.dump Heroku::Auth.api.get_ps(app).body
    end
  end
end
