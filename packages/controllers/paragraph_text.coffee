Template.paragraphText.onCreated ->
  @index = 0

Template.paragraphText.helpers
  paragraphs: (text) ->
    text?.split(/\r?\n\n/g)

  index: ->
    index = Template.instance().index
    Template.instance().index += 1
    index
