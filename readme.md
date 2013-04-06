Flatiron Persona
================

[Broadway](https://github.com/flatiron/broadway) plugin for user authentication using [Mozilla Persona](http://www.mozilla.org/en-US/persona/)

How to use it
-------------

Get it with:

```bash
npm install git://git@github.com:lzrski/flatiron-persona.git
```

``` coffeescript
# app.coffee

flatiron = require 'flatiron'
persona  = require 'flatiron-persona'
connect  = require "connect"
app      = flatiron.app;

app.use flatiron.plugins.http
app.use persona, audience: "http://example.com/"

# You need session. Session needs cookieParser. So:
app.http.before.push do connect.cookieParser
app.http.before.push connect.session secret: "
  Kiedy nikogo nie ma w domu, Katiusza maluje pazury na zielono i śmieje się po cichu do lustra. To prawda!"

app.start 4000;
```

If you use [Creamer](https://github.com/twilson63/creamer/) like I do, that's what your `views/layout.coffee` might look like:

``` coffeescript
module.exports = ->
  ###
    If user is logged in @session.username will be set to his e-mail address.
    Let's make a convenient shortcut.
  ###
  if @session?.username? then @username = @session.username

  doctype 5
  html ->
    head ->
      title "Persona authentication demo"
      meta charset: "utf-8"
      meta "http-equiv": "X-UA-Compatible", content: "IE=Edge"

      script src: "https://login.persona.org/include.js"

      # I'll use jquery here. You don't have to.
      script src: "http://code.jquery.com/jquery-1.9.1.min.js"
      script src: "http://code.jquery.com/jquery-migrate-1.1.1.min.js"

    # data-username indicates that user is logged in - see below. Again, you can take different approach.
    body "data-username": @username, ->
      header ->
        h1 "Persona authentication demo"
        
        unless @username # if not logged in...
          a {
            id: "signin"
            href: "#"
            class: "persona-button dark"
          }, ->  span "Log in"
        else
          a {
            id: "signout"
            href: "#"
            class: "persona-button blue"
          }, ->  span "Logout #{@username}"

      section id: "main", ->
        do content

      footer ->
        p "A juicy footer is here as well :)"

      coffeescript ->
        ($ document).ready ->
          # That's why we had to set data-username on body - this script will be compiled into JS and won't have access to outside variables like @session.
          username = ($ "body").data "username" ? null
          if username then console.log "Logged in as #{username}"
          else console.log "Not logged in (yet?)"

          # Now goes Persona stuff, see https://developer.mozilla.org/en-US/docs/Persona/Quick_Setup
          navigator.id.watch {
            loggedInUser: username
            onlogin     : (assertion) ->
              console.log "Logging in..."
              $.ajax {
                type  : "POST"
                url   : "/auth/login"
                data  : 
                  assertion : assertion
                success : -> do window.location.reload
                error   : (xhr, status, error) -> 
                  console.dir xhr
                  do navigator.id.logout
              }
            onlogout    : ->
              console.log "Logging out..."
              $.ajax {
                type  : "POST"
                url   : "/auth/logout"
                success : -> do window.location.reload
                error   : (xhr, status, error) -> console.error "Logout failed: #{error}"
              }
          }

          ($ "#signin").click  -> do navigator.id.request
          ($ "#signout").click -> do navigator.id.logout
```

Options
-------

When calling app.use persona you can provide following options:

<dl>
  <dt>audience</dt>
  <dl>BrowserID audience (ie. your application url). There's no default value and you must provide this option. See https://developer.mozilla.org/en-US/docs/Persona/Quick_Setup#Step_4.3A_Verify_the_user.E2.80.99s_credentials for more details.</dl>

  <dt>path</dt>
  <dl>Route prefix, defaults to /auth</dl>

To dos
------

* Tests (preferably in [Mocha](http://visionmedia.github.io/mocha/))
* Examples
* Cakefile and compilation to JS
* Publish on NPM