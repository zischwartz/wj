_str = require("underscore.string")

module.exports =
	registerHbs: (handlebars)->
		handlebars.registerHelper 'replaceUnderscores', (s) ->
		  s.replace(/_/g,' ')

		handlebars.registerHelper "default", (data, options) ->
		  if data then return data
		  else return options

		handlebars.registerHelper "ifPage", (context, options) ->
		  if @meta.isHtml and not @meta.isIndex
		    return context.fn(this)

		domain = require('domain')
		d = domain.create()
		d.on 'error', (err)->
		  console.log err
		handlebars.registerHelper 'json', (obj) ->
		  d.run ->
		    out = {}
		    for key, value of obj
		      out[key]= {}
		      if typeof value in ['string', 'boolean']
		        out[key]= value
		      else
		        for i, j of value
		          if typeof j in ['string', 'boolean']
		            out[key][i] = [j]
		    return JSON.stringify(out)
		return handlebars

	  	handlebars.registerHelper "slugify", (str) ->
	    	new Handlebars.SafeString(_str.slugify(str))