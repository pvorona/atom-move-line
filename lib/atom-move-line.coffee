{CompositeDisposable} = require 'atom'

module.exports = MoveLine =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'editor:move-line-up':   => @moveUp()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'editor:move-line-down': => @moveDown()

  deactivate: ->
    @subscriptions.dispose()

  moveUp: ->
    moveLines = ({row}) ->
      currentRowText = editor.lineTextForBufferRow(row)
      previousRowText = editor.lineTextForBufferRow(row + 1)
      if not previousRowText.endsWith ',' then return
      if currentRowText.endsWith ',' then return
      if not previousRowText.includes ':' then return
      editor.setTextInBufferRange([{row: row, column: currentRowText.length}, {row: row, column: currentRowText.length}], ',')
      editor.setTextInBufferRange([{row: row + 1, column: 0}, {row: row + 1, column: previousRowText.length}], previousRowText.substring(0, previousRowText.length - 1))

    editor = atom.workspace.getActiveTextEditor()
    selectionRanges = editor.getSelectedBufferRanges()
    editor.getCursorBufferPositions().forEach(moveLines)
    editor.setSelectedBufferRanges(selectionRanges)


  moveDown: ->
    moveLines = ({row}) ->
      currentRowText = editor.lineTextForBufferRow(row)
      nextRowText = editor.lineTextForBufferRow(row - 1)
      if not currentRowText.endsWith ',' then return
      if nextRowText.endsWith ',' then return
      if not nextRowText.includes ':' then return
      editor.setTextInBufferRange([{row: row - 1, column: nextRowText.length}, {row: row - 1, column: nextRowText.length}], ',')
      editor.setTextInBufferRange([{row: row, column: 0}, {row: row, column: currentRowText.length}], currentRowText.substring(0, currentRowText.length - 1))

    editor = atom.workspace.getActiveTextEditor()
    selectionRanges = editor.getSelectedBufferRanges()
    editor.getCursorBufferPositions().reverse().forEach(moveLines)
    editor.setSelectedBufferRanges(selectionRanges)
