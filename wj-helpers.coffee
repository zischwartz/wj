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
		return handlebars