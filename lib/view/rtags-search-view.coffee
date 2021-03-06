{$, View} = require 'space-pen'
rtags = require '../rtags'

module.exports =
  class RtagsSearchView extends View
    @content: ->
      @form =>
        @input class: 'input-text native-key-bindings', type: 'text', outlet: 'textbox'

    initialize: () ->
      @panel = null
      @searchCallback = null
      @lastFocusedElement = null

    setSearchCallback: (callback) ->
      @searchCallback = callback

    show: ->
      @textbox.val('')
      @lastFocusedElement = $(document.activeElement)
      @panel = atom.workspace.addModalPanel({item: @})
      @textbox.focus()
      @textbox.keydown(@handleKeydown)


    hide: ->
      @panel?.destroy()
      @lastFocusedElement?.focus()
      @textbox.unbind('keydown', @handleKeydown)

    handleKeydown: (event) =>
      if event.keyCode == 13
        @searchCallback?(@textbox.val())
        @hide()
      else if event.keyCode == 27
        @hide()
      return
