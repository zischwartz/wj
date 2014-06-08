_str = require("underscore.string")
path = require("path")

label_size = (path, size) ->
  tokens = path.split('.')
  ext= tokens.pop()
  tokens[-1..] = tokens[-1..]+size
  tokens.push(ext)
  tokens.join('.')

module.exports =
    label_size: label_size

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

        handlebars.registerHelper "slugify", (str) ->
            new handlebars.SafeString(_str.slugify(str))
        
        handlebars.registerHelper 'label_size', (path, size)->
          label_size(path, size)

        handlebars.registerHelper "imagesInSect", (context, options) ->
          # console.log this
          res = ''
          if @page.hide_image_index then return res
          for f in @page.section.files
            if not f.meta.isHtml
              res+= context.fn f
          # console.log 'res'
          # console.log res
          res
          # if @meta.isHtml and not @meta.isIndex
            # return context.fn(this)

        # Important: finally, return hbs
        handlebars


    #     {{!-- Images in this Dir --}}
    #     {{#each page.section.files}}
    #         {{#unless meta.isHtml}}
    #             <img src="{{../../site.baseUrl}}{{relative}}" title="{{meta.name}}" id="{{slugify meta.name}}" alt="{{meta.name}}" class="big_image">
    #         {{/unless}}
    #     {{/each}}
    # {{/if}} {{!-- / is index --}}