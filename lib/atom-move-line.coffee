{CompositeDisposable} = require 'atom'

module.exports = MoveLine =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'editor:move-line-up':   => @preservingSelection(@moveUp)
    @subscriptions.add atom.commands.add 'atom-text-editor', 'editor:move-line-down': => @preservingSelection(@moveDown)

  deactivate: ->
    @subscriptions.dispose()

  preservingSelection: (action) ->
    editor = atom.workspace.getActiveTextEditor()
    selectionRanges = editor.getSelectedBufferRanges()
    action(editor)
    editor.setSelectedBufferRanges(selectionRanges)

  moveUp: (editor) ->
    moveLines = ({row}) ->
      lastLine = ->
        previousRowText.endsWith(',') and not currentRowText.endsWith(',')
      declaration = ->
        currentRowText.endsWith('{') or currentRowText.endsWith('[')
      currentRowText = editor.lineTextForBufferRow(row)
      previousRowText = editor.lineTextForBufferRow(row + 1)
      return unless lastLine()
      return if declaration()
      editor.setTextInBufferRange([{row: row, column: currentRowText.length}, {row: row, column: currentRowText.length}], ',')
      editor.setTextInBufferRange([{row: row + 1, column: 0}, {row: row + 1, column: previousRowText.length}], previousRowText.substring(0, previousRowText.length - 1))
    editor.getCursorBufferPositions().forEach(moveLines)

  moveDown: (editor) ->
    moveLines = ({row}) ->
      lastLine = ->
        currentRowText.endsWith(',') and not nextRowText.endsWith(',')
      declaration = ->
        nextRowText.endsWith('{') or nextRowText.endsWith('[')
      currentRowText = editor.lineTextForBufferRow(row)
      nextRowText = editor.lineTextForBufferRow(row - 1)
      return unless lastLine()
      return if declaration()
      editor.setTextInBufferRange([{row: row - 1, column: nextRowText.length}, {row: row - 1, column: nextRowText.length}], ',')
      editor.setTextInBufferRange([{row: row, column: 0}, {row: row, column: currentRowText.length}], currentRowText.substring(0, currentRowText.length - 1))
    editor.getCursorBufferPositions().reverse().forEach(moveLines)
