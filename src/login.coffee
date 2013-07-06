request = require "request"
debug   = require "debug"
$       = debug "persona:login"

module.exports = ->
  if not @req.session? then throw new Error """
    flatiron-persona: There is no session object in request.

      Flatiron Persona plugin needs to set @req.session.username to indicate that user is authenticated.

      Make sure your application supports session.  You may use connect session middleware, as shown here: https://github.com/lzrski/flatiron-persona#flatiron-persona
  """
  if not @req.body or not @req.body.assertion
    $ "No assertion given. Body is:", @req.body
    @res.json 400, {error: "No assertion given"}
    return 
  
  $ "Authenticating user to %s", @persona.audience
  
  verifier =
    url   : "https://verifier.login.persona.org/verify"
    json  : true
    body  :
      assertion : @req.body.assertion
      audience  : @persona.audience

  request.post verifier, (error, response, body) =>
    $ = debug "persona:login:verification"
    if error
      $ "Error: %j", error
      @res.json 500, {error: "Verification error"}
      return
    
    $ "Verification response body %j", body
    if body.status is "okay"
      $ "User %s authorized", body.email

      @req.session.username = body.email
      do @req.session.save # Do we need that?
      @res.json 200, { username: body.email }
    else 
      $ "Authorization failed"
      @res.json 401, {}
