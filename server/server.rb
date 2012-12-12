require 'sinatra'
require 'sinatra-websocket'
require 'heroku'

module Cabin
  class Server < Sinatra::Application
    def app
      ENV['APP'] || 'will'
    end

    get '/' do
      @app = app
      erb :index
    end

    get '/logs' do
      if request.websocket?
        request.websocket do |ws|
          ws.onopen {
            EM.next_tick {
              # THREADS thank you
              # https://github.com/sseforce/heroku_pusher/blob/master/app.rb
              @thread = Thread.new do
                Heroku::Auth.client.read_logs(app, ['tail=1']) { |line| ws.send line }
              end
            }
          }
       end
      else # not websocket
        stream(:keep_open) do |out|
          EM::PeriodicTimer.new(20) { out << "\0" }
          Heroku::Auth.client.read_logs(app, ['tail=1']) { |line| out << line }
        end
      end
    end

  end
end
