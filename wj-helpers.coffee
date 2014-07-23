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

        handlebars.registerHelper 'defaultNoUnderscores', (data, options) ->
          if data then return data.replace(/_/g,' ')
          else return options.replace(/_/g,' ')

        handlebars.registerHelper "default", (data, options) ->
          if data then return data
          else return options

        handlebars.registerHelper "ifPage", (context, options) ->
          if @meta.isHtml and not @meta.isIndex
            return context.fn(this)

        handlebars.registerPartial 'pageLink',
        '{{#ifPage}}<br>
            <a href="{{meta.url}}">
            {{defaultNoUnderscores meta.title meta.name}}
            {{#if meta.media}} <img src="{{meta.media}}" /> {{/if}}
            </a>
         {{/ifPage}}'

        handlebars.registerPartial 'sectionLink',
        '''{{#each site.index.sections}}
              <a href="{{url}}"> {{defaultNoUnderscores name title}}</a>
           {{/each}}'''

        # XXX imageThumbA and imageThumbI should be the below, without the added slash at the start of the urls, handlebars is removing it evidently? https://github.com/wycats/handlebars.js/issues/268
        # <a href="{{../../site.baseUrl}}{{relative}}" class="thumb_image" title="{{meta.caption}}"  style="background-image: url('{{../../site.baseUrl}}{{label_size relative "-small"}}')"></a>
        # <a href="/{{../../site.baseUrl}}{{relative}}" class="thumb_image" title="{{meta.caption}}"  style="background-image: url('/{{../../site.baseUrl}}{{label_size relative "-small"}}')"></a>

        handlebars.registerPartial 'imageThumbA',
        '''
        <a href="/{{../../site.baseUrl}}{{relative}}" class="thumb_image" title="{{meta.caption}}"  style="background-image: url('/{{../../site.baseUrl}}{{label_size relative "-small"}}')"></a>
        '''

        handlebars.registerPartial 'imageThumbI',
        '''
        <img src="/{{../../site.baseUrl}}{{label_size relative '-small'}}" title="{{meta.caption}}" id="{{slugify meta.name}}" alt="{{meta.caption}}" class="thumb_image">
        '''

        # d is all just for debugging
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
          # console.log @page.captions
          if @page?.hide_image_index then return res
          for f in @page.section.files
            if not f.meta.isHtml
              caption = @?page.captions[f.meta.name]
              if caption then f.meta.caption = caption
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