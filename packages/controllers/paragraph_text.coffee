Template.paragraphText.onCreated ->
  @index = 0

Template.paragraphText.helpers
  paragraphs: (text) ->
    text?.split(/\r?\n\n/g)
