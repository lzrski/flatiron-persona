_     = require "underscore"
debug = require "debug"
$     = debug "persona"

module.exports =
  name    : "flatiron-persona"
  attach  : (options) ->
    $     = debug "persona:attach"

    defaults =
      path: "/auth"
      audience: undefined
    _.defaults options, defaults
    $ "Options: %j", options

    if not options.audience then throw new Error """
      flatiron-persona: Audience not set.

      You must provide an audience in options, eg.

        app.use persona, audience: "http://myapp.example.com/"

      Learn more about audience here: https://developer.mozilla.org/en-US/docs/Persona/Quick_Setup#Step_4.3A_Verify_the_user.E2.80.99s_credentials
      
    """

    if not @router? then throw new Error """
      flatiron-persona: There is no router in your app.

      This plugin is for http apps only with Director router. Make sure you do
      (Coffeescript):

        app.use flatiron.plugins.http

      or (in plain Javascript):

        app.use (flatiron.plugins.http);

      before you use this plugin. Thank you :)

      """
    routes = {}
    routes[options.path] = 
      "/login":
        post: require "./login"
      "/logout":
        post: require "./logout"
    
    @router.mount routes
    @router.attach ->
      $ = debug "persona:attach:router-attach"

      @persona ?= {}
      @persona.audience ?= options.audience

  detach  : ->
  init    : (done) ->
    $ = debug "persona:init"
    app = @
    @router.attach ->
      $ = debug "persona:init:router-attach"
      {address, port} = app.server.address()
      @persona ?= {}
      @persona.audience ?= "http://#{address}:#{port}/"

    do done
