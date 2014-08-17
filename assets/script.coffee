console.log 'hi'

$ ->
  # $('a.thumb_image').on 'click', (e)->
  #   $('.wrapper').fadeOut('fast')
  #   e.preventDefault()
  #   e.stopPropagation()
  #   href = $(@).attr 'href'
  #   $('body').addClass 'showing_image'
  #   $('body').css
  #     'background-image': "url('#{href}')"

  #   # and then to get rid of it
  #   $('body.showing_image').on 'click', ->
  #     $('body').removeClass 'showing_image'
  #     $('.wrapper').fadeIn()
  #     $('body').css
  #       'background-image': false