module.exports = ->
  if not @req.session? then throw new Error """
    flatiron-persona: There is no session object in request.

      Flatiron Persona plugin needs to set @req.session.username to indicate that user is authenticated.

      Make sure your application supports session.  You may use connect session middleware, as shown here: https://github.com/lzrski/flatiron-persona#flatiron-persona
  """

  @log.debug "Logging out user #{@req.session.username}"
  @req.session.destroy (error) =>
    if error
      @log.warn "Logout error.", error
      @res.json 500, {error: "Logout error."}
      return
    
    @res.json 200, {}