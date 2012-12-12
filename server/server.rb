require 'sinatra'
require 'heroku'

module Cabin
  class Server < Sinatra::Application
    get '/' do
      erb :index
    end

    get '/logs' do
      app = 'will'
      stream(:keep_open) do |out|
        EM::PeriodicTimer.new(20) { out << "\0" }
        Heroku::Auth.client.read_logs(app, ['tail=1']) { |line| out << line }
      end
    end

  end
end
