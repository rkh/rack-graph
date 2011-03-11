require 'rack'

module Rack
  module Handler
    autoload :Graph, 'rack/handler/graph'
    register 'graph', 'Graph'
    register 'Graph', 'Graph'
  end
end
