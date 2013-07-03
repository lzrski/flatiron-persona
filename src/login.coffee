request = require "request"
module.exports = ->
  if not @req.session? then throw new Error """
    flatiron-persona: There is no session object in request.

      Flatiron Persona plugin needs to set @req.session.username to indicate that user is authenticated.

      Make sure your application supports session.  You may use connect session middleware, as shown here: https://github.com/lzrski/flatiron-persona#flatiron-persona
  """
  if not @req.body or not @req.body.assertion
    @log.debug "No assertion given. Body is:", @req.body
    @res.json 400, {error: "No assertion given."}
    return 
  
  @log.debug "Authenticating user to #{@persona.audience}"
  
  a = @ # allows to use data and methods of @ during verification
  verifier =
    url   : "https://verifier.login.persona.org/verify"
    json  : true
    body  :
      assertion : @req.body.assertion
      audience  : @persona.audience

  request.post verifier, (error, response, body) =>
    if error
      @log.warn "Verification error.", error
      @res.json 500, {error: "Verification error."}
      return
    @log.debug "Verification response body:", body
    if body.status is "okay"
      @log.debug "User #{body.email} authorized."

      @req.session.username = body.email
      do @req.session.save
      @res.json 200, { username: body.email }
    else 
      @log.debug "Authorization failed."
      @res.json 401, {}
