#require 'rack/cors'

require_relative 'api/api'

module POSConnector
  class Main
    def initialize
      @index = '/index.html'
      @rack_static = ::Rack::Static.new(
        lambda { [404, {}, []] },
        root: File.expand_path('../../public', __FILE__),
        urls: ['/']
      )
    end

    def self.instance
      @instance ||= Rack::Builder.new do
        # For handling Cross-Origin Resource Sharing (CORS)
        #use Rack::Cors do
        #  allow do
        #    origins '*'
        #    resource '*', headers: :any, methods: :get
        #  end
        #end

        run POSConnector::Main.new
      end.to_app
    end

    def call(env)
      request_path = env['PATH_INFO']

      if request_path.start_with?('/api/')
        response = POSConnector::API::API.call(env)
      else
        if request_path == '/' or not (request_path.end_with?('.html') or request_path.end_with?('.js') or request_path.end_with?('.css'))
          # Direct all the non-static file requests to the index page
          response = @rack_static.call(env.merge('PATH_INFO' => @index))
        else
          # Serve static files
          response = @rack_static.call(env)
        end
      end

      response
    end
  end
end
