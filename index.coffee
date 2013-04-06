request = require "request"

module.exports =
  name    : "flatiron-persona"
  attach  : (options) ->
    if not @router then throw new Error """
      There is no router in your app.
      This plugin is for http apps only with Director router. Make sure you do
      (Coffeescript):

        app.use flatiron.plugins.http

      or (in plain Javascript):

        app.use (flatiron.plugins.http);

      before you use this plugin. Thank you :)

      """

    @router.mount {
      "/auth":
        "/login":
          post: ->
            @res.end "Authenticating..."
        "/logout":
          post: ->
            @res.end "Bye bye!"
    }
  detach  : ->
  init    : (done) ->
    do done
