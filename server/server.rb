require 'sinatra'
require 'heroku'

module Cabin
  class Server < Sinatra::Application
    get '/' do
      'toot'
    end

    get '/logs' do
      app = 'will'
      stream(:keep_open) do |out|
        Heroku::Auth.client.read_logs(app, ['tail=1']) do |line|
          out << line
        end
      end
    end

  end
end
