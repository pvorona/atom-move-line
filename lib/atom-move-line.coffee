{CompositeDisposable} = require 'atom'

module.exports = MoveLine =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'editor:move-line-up':   => @withActiveEditor(@preservingSelections(@moveUp))
    @subscriptions.add atom.commands.add 'atom-text-editor', 'editor:move-line-down': => @withActiveEditor(@preservingSelections(@moveDown))

  deactivate: ->
    @subscriptions.dispose()

  withActiveEditor: (action) ->
    editor = atom.workspace.getActiveTextEditor()
    action(editor)

  preservingSelections: (action) -> (editor) ->
    selectionRanges = editor.getSelectedBufferRanges()
    action(editor)
    editor.setSelectedBufferRanges(selectionRanges)

  moveUp: (editor) ->
    moveLines = ({row}) ->
      lastLine = (prevLine, lastLine) ->
        prevLine.endsWith(',') and not lastLine.endsWith(',')
      declaration = (line) ->
        line.endsWith('{') or line.endsWith('[')
      moveToEndOfLine = (line) ->
        editor.setCursorBufferPosition([line, 0])
        editor.moveToEndOfLine()
      addComma = (row) ->
        moveToEndOfLine(row)
        editor.insertText(',')
      removeComma = (row) ->
        moveToEndOfLine(row)
        editor.backspace()
      prevRow = row + 1
      currentRowText = editor.lineTextForBufferRow(row)
      previousRowText = editor.lineTextForBufferRow(prevRow)
      return unless lastLine(previousRowText, currentRowText)
      return if declaration(currentRowText)
      addComma(row)
      removeComma(prevRow)
    editor.getCursorBufferPositions().forEach(moveLines)

  moveDown: (editor) ->
    moveLines = ({row}) ->
      lastLine = (prevLine, lastLine) ->
        prevLine.endsWith(',') and not lastLine.endsWith(',')
      declaration = (line) ->
        line.endsWith('{') or line.endsWith('[')
      moveToEndOfLine = (line) ->
        editor.setCursorBufferPosition([line, 0])
        editor.moveToEndOfLine()
      addComma = (row) ->
        moveToEndOfLine(row)
        editor.insertText(',')
      removeComma = (row) ->
        moveToEndOfLine(row)
        editor.backspace()
      nextRow = row - 1
      currentRowText = editor.lineTextForBufferRow(row)
      nextRowText = editor.lineTextForBufferRow(nextRow)
      return unless lastLine(currentRowText, nextRowText)
      return if declaration(nextRowText)
      addComma(nextRow)
      removeComma(row)
    editor.getCursorBufferPositions().reverse().forEach(moveLines)
