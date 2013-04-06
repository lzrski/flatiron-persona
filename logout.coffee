module.exports = ->
  if not @req.session? then throw new Error """
    flatiron-persona: There is no session object in request.

      Flatiron Persona plugin needs to set @req.session.username to indicate that user is authenticated.

      Make sure your application supports session.  You may use connect session middleware, as shown here: https://github.com/lzrski/flatiron-persona#flatiron-persona
  """

  @log.debug "Logging out user #{@req.session.username}"
  a = @ # allows to use data and methods of @ during verification
  @req.session.destroy (error) ->
    if error
      a.log.warn "Logout error.", error
      a.res.json 500, {error: "Logout error."}
      return
    
    a.res.json 200, {}