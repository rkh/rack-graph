Generates a Rack middleware tree.

Usage:

    $ rackup -s Graph           # with config.ru
    $ ruby my_app.rb -s Graph   # Sinatra
    $ script/server Graph       # Rails 2.3
    $ rails server Graph        # Rails 3.x

Example:

    $ ruby -I rack-graph/lib rkh.im/blog.rb -s Graph
    Sinatra::ShowExceptions
     |- Rack::MethodOverride
        |- Rack::Head
           |- Rack::CommonLogger(nil)
              |- Rack::Logger
                 |- Sinatra::Application(public: "/Users/konstantin/Workspace/rkh.im/public") < Sinatra::Base
                    |- "GET"
                    |  |- "/seaside"
                    |  |  |- Proc(0x0000010135e7e0, /Users/konstantin/.rvm/gems/ruby-1.9.2-p290/gems/sinatra-1.3.0/lib/sinatra/base.rb:1116)
                    |  |
                    |  |- /^\/code(?:\-|%2D)reloading$/
                    |  |  |- Proc(0x00000101354b28, /Users/konstantin/.rvm/gems/ruby-1.9.2-p290/gems/sinatra-1.3.0/lib/sinatra/base.rb:1116)
                    |  |
                    |  |- "/"
                    |  |  |- Proc(0x000001013524e0, /Users/konstantin/.rvm/gems/ruby-1.9.2-p290/gems/sinatra-1.3.0/lib/sinatra/base.rb:1116)
                    |  |
                    |  |- /^\/feed(?:\.|%2E)xml$/
                    |  |  |- Proc(0x00000101350578, /Users/konstantin/.rvm/gems/ruby-1.9.2-p290/gems/sinatra-1.3.0/lib/sinatra/base.rb:1116)
                    |  |
                    |  |- /^\/style(?:\.|%2E)css$/
                    |  |  |- Proc(0x0000010134dbc0, /Users/konstantin/.rvm/gems/ruby-1.9.2-p290/gems/sinatra-1.3.0/lib/sinatra/base.rb:1116)
                    |  |
                    |  |- "/:year/:month/:slug"
                    |  |  |- Proc(0x0000010134aa60, /Users/konstantin/.rvm/gems/ruby-1.9.2-p290/gems/sinatra-1.3.0/lib/sinatra/base.rb:1116)
                    |  |
                    |  |- /^\/__sinatra__\/([^\/?#]+)(?:\.|%2E)png$/
                    |     |- Proc(0x0000010131afb8, /Users/konstantin/.rvm/gems/ruby-1.9.2-p290/gems/sinatra-1.3.0/lib/sinatra/base.rb:1116)
                    |
                    |- "HEAD"
                       |- "/seaside"
                       |  |- Proc(0x0000010135d8e0, /Users/konstantin/.rvm/gems/ruby-1.9.2-p290/gems/sinatra-1.3.0/lib/sinatra/base.rb:1116)
                       |
                       |- /^\/code(?:\-|%2D)reloading$/
                       |  |- Proc(0x00000101353430, /Users/konstantin/.rvm/gems/ruby-1.9.2-p290/gems/sinatra-1.3.0/lib/sinatra/base.rb:1116)
                       |
                       |- "/"
                       |  |- Proc(0x00000101351b30, /Users/konstantin/.rvm/gems/ruby-1.9.2-p290/gems/sinatra-1.3.0/lib/sinatra/base.rb:1116)
                       |
                       |- /^\/feed(?:\.|%2E)xml$/
                       |  |- Proc(0x0000010134f128, /Users/konstantin/.rvm/gems/ruby-1.9.2-p290/gems/sinatra-1.3.0/lib/sinatra/base.rb:1116)
                       |
                       |- /^\/style(?:\.|%2E)css$/
                       |  |- Proc(0x0000010134c658, /Users/konstantin/.rvm/gems/ruby-1.9.2-p290/gems/sinatra-1.3.0/lib/sinatra/base.rb:1116)
                       |
                       |- "/:year/:month/:slug"
                       |  |- Proc(0x00000101349728, /Users/konstantin/.rvm/gems/ruby-1.9.2-p290/gems/sinatra-1.3.0/lib/sinatra/base.rb:1116)
                       |
                       |- /^\/__sinatra__\/([^\/?#]+)(?:\.|%2E)png$/
                          |- Proc(0x0000010131a540, /Users/konstantin/.rvm/gems/ruby-1.9.2-p290/gems/sinatra-1.3.0/lib/sinatra/base.rb:1116)
