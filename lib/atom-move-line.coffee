{CompositeDisposable} = require 'atom'

withActiveEditor = (action) ->
  action(atom.workspace.getActiveTextEditor())

collapsingHistory = (action) -> (editor) ->
  editor.transact(100, -> action(editor))

preservingSelections = (action) -> (editor) ->
  selections = editor.getSelectedBufferRanges()
  action(editor)
  editor.setSelectedBufferRanges(selections)

lastLine = (prevLine, lastLine) ->
  prevLine.endsWith(',') and not lastLine.endsWith(',')

declaration = (line) ->
  line.endsWith('{') or line.endsWith('[')

atTheEndOfLine = (line, action) -> (editor) ->
  editor.setCursorBufferPosition([line])
  editor.moveToEndOfLine()
  action()

moveLines = (prevRow, lastRow) -> (editor) ->
  [prevLineText, lastLineText] = [editor.lineTextForBufferRow(prevRow), editor.lineTextForBufferRow(lastRow)]
  return if not lastLine(prevLineText, lastLineText) or declaration(lastLineText)
  atTheEndOfLine(lastRow, => editor.insertText(','))(editor)
  atTheEndOfLine(prevRow, => editor.backspace())(editor)

moveUp = (editor) ->
  editor.splitSelectionsIntoLines()
  editor.getCursorsOrderedByBufferPosition().map((c) -> c.getBufferRow()).forEach (row) -> moveLines(row + 1, row)(editor)

moveDown = (editor) ->
  editor.splitSelectionsIntoLines()
  editor.getCursorsOrderedByBufferPosition().map((c) -> c.getBufferRow()).forEach (row) -> moveLines(row, row - 1)(editor)

subscriptions =
  'editor:move-line-up'  : => withActiveEditor collapsingHistory preservingSelections moveUp
  'editor:move-line-down': => withActiveEditor collapsingHistory preservingSelections moveDown

module.exports =
  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', subscriptions

  deactivate: ->
    @subscriptions.dispose()
