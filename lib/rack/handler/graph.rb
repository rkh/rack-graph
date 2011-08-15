require 'rack'

module Rack
  module Handler
    module Graph
      CustomInspect = Struct.new(:inspect)

      unless respond_to? :__method__
        ::Object.send(:alias_method, :__method__, :method)
      end

      class Wrapper
        include Enumerable

        @map = {}
        def self.[](key)          @map[key.to_s]          end
        def self.[]=(key, value)  @map[key.to_s] = value  end

        def self.wraps(*klasses)
          klasses.each { |k| Wrapper[k] = self }
        end

        def self.new(app, *args)
          return super if self != Wrapper
          klass = app.class
          while klass
            if wrapper = Wrapper[klass]
              return wrapper.new(app, *args)
            else
              klass = klass.superclass
            end
          end
          raise ArgumentError, "unable to handle #{app.inspect}"
        end

        attr_accessor :app

        def initialize(app)
          @app = app
        end

        def call(env)
          app.call(env)
        end

        def wrap(a)
          return a if Wrapper === a
          Wrapper.new(a)
        end

        def graph(out = $stdout, prefix = "", last = false)
          if prefix.empty?
            out.puts name
            last = true
          else
            out.puts "#{prefix}#{"|" if last}- #{name}"
            prefix += "  "
          end
          prefix += " " if last
          children[0..-2].each do |c|
            sub = prefix + "|"
            wrap(c).graph(out, sub)
            out.puts sub
          end
          unless children.empty?
            wrap(children.last).graph(out, prefix, true)
          end
        end

        def options
        end

        def options?
          options and not options.respond_to?(:empty?) && options.empty?
        end

        def name
          app.class.name + (options? ? "(#{Array(options).join ", "})" : "")
        end

        def ivar(name)
          name = name.to_s
          name = "@" << name unless name.start_with? "@"
          app.instance_variable_get name
        end

        def child
          children.size < 2 ? children.first : children
        end

        alias_method :next, :child

        def children
          []
        end

        def each(&block)
          children.each(&block)
        end

        def io(io)
          case io
          when $stdout then "stdout"
          when $stderr then "stderr"
          when $stdin  then "stdin"
          when File    then io.path
          else io.inspect
          end
        end
      end

      class GenericWrapper < Wrapper
        wraps Object, :BasicObject

        def looks_good?(obj)
          return if obj.equal? app
          looks_like_app? obj or
          looks_like_map? obj or
          looks_like_list? obj
        end

        def looks_like_app?(obj)
          return unless obj.respond_to?(:call)
          obj.respond_to?(:arity) && obj.arity == 1 or
          obj.__method__(:call).arity == 1
        end

        def looks_like_list?(list)
          list.respond_to? :any? and
          list.respond_to? :all? and
          list.respond_to? :to_a and
          list.any?              and
          list.all? { |e| looks_like_app? e }
        end

        def looks_like_map?(map)
          map.respond_to? :values     and
          map.respond_to? :each_pair  and
          map.values.any?             and
          map.values.all? { |e| looks_like_app? e }
        end

        def url_map(map)
          map.map { |k,v| MapEntry.new k, v }
        end

        def children
          list = begin
            if    app.respond_to? :apps then app.apps
            elsif app.respond_to? :app  then app.app
            elsif a = ivar(:apps)       then a
            elsif a = ivar(:app)        then a
            else
              app.instance_variables.
                map { |n| ivar(n) }.
                select { |e| looks_good? e }.
                map { |e| Hash === e ? url_map(e) : e }
            end
          end
          Array(list).flatten
        end
      end

      class LogWrapper < GenericWrapper
        wraps Rack::CommonLogger
        def options
          io ivar(:logger)
        end
      end

      class MapEntry < Wrapper
        attr_reader :name
        def initialize(name, child)
          @name, @child = name.inspect, child
        end

        def children
          Array(@child).flatten
        end

        def call(env)
          @child.call(env)
        end
      end

      class URLMapWrapper < Wrapper
        wraps Rack::URLMap
        def children
          ivar(:mapping).map do |host, location, match, app|
            if host and not host.empty?
              name = "http[s]://" << host
              if location
                name << '/' unless location.start_with? '/'
                name << location
              end
            else
              name = location
            end
            MapEntry.new name, app
          end
        end
      end

      class ProcWrapper < Wrapper
        wraps Proc

        def options
          app.inspect[7..-2].sub('@', ', ')
        end
      end

      class ClassWrapper < Wrapper
        SAFE_CLASS = %w[Sinatra::Base]
        wraps Class

        def self.new(app)
          if SAFE_CLASS.any? { |c| app.ancestors.any? { |a| a.to_s == c }}
            Wrapper.new app.new
          else
            GenericWrapper.new app
          end
        end
      end

      class ConfigWrapper < GenericWrapper
        wraps Rack::Config
        def options
          ProcWrapper.new(ivar(:block)).name
        end
      end

      class SinatraWrapper < Wrapper
        wraps 'Sinatra::Base'

        def settings
          app.settings
        end

        def children
          kids = all_routes.map do |verb, routes|
            MapEntry.new verb,
              routes.map { |r| MapEntry.new decompile(r), r.last }
          end
          kids << app.app if app.app
          kids
        end

        def options
          return unless settings.static?
          dir = Sinatra::VERSION < '1.3' ? settings.public : settings.public_folder
          "public: #{dir.inspect}" if dir and ::File.exist? dir
        end

        def decompile(pattern, keys = nil, *)
          pattern, keys = pattern if pattern.respond_to? :to_ary
          keys, str     = keys.dup, pattern.inspect
          return pattern unless str.start_with? '/^' and str.end_with? '$/'
          str = str[2..-3].gsub /\\([\.\+\(\)\/])/, '\1'
          str.gsub /\([^\(]*\)/ do |part|
            case part
            when '(.*?)'
              return pattern if keys.shift != 'splat'
              '*'
            when '([^/?#]+)'
              return pattern if keys.empty?
              ":" << keys.shift
            else
              return pattern
            end
          end
        end

        def all_routes
          routes = Hash.new { |h,k| h[k] = [] }
          app.settings.ancestors.each do |klass|
            next unless klass.respond_to? :routes
            klass.routes.each do |verb, list|
              routes[verb].concat list
            end
          end
          routes
        end

        def name
          app.class == Sinatra::Base ? super : super << ' < Sinatra::Base'
        end
      end

      class RackMountWrapper < Wrapper
        wraps 'Rack::Mount::RouteSet'
        def children
          ivar(:routes).map do |route|
            MapEntry.new route.conditions, route.app
          end
        end
      end

      def self.run(app, options = {})
        new(app).graph
      end

      def self.new(app)
        Wrapper.new(app)
      end
    end
  end

  Graph = Handler::Graph
end
