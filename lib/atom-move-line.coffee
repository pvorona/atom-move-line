{CompositeDisposable} = require 'atom'

withActiveEditor = (action) ->
  action atom.workspace.getActiveTextEditor()

collapsingHistory = (action) -> (editor) ->
  editor.transact 100, action.bind(this, editor)

preservingSelections = (action) -> (editor) ->
  selections = editor.getSelectedBufferRanges()
  action editor
  editor.setSelectedBufferRanges selections

splittingMultilineSelections = (action) -> (editor) ->
  editor.splitSelectionsIntoLines()
  action editor

atTheEndOfLine = (line, action) -> (editor) ->
  editor.setCursorBufferPosition [line]
  editor.moveToEndOfLine()
  action()

lastLine = (prevLine, lastLine) ->
  prevLine.endsWith(',') and not lastLine.endsWith(',')

declaration = (line) ->
  ['{', '['].some (terminator) -> line.endsWith terminator

moveLastChar = (from, to) -> (editor) ->
  [fromLine, toLine] = [editor.lineTextForBufferRow(from), editor.lineTextForBufferRow(to)]
  return unless lastLine(fromLine, toLine) and not declaration(toLine)
  lastChar = fromLine[fromLine.length - 1]
  atTheEndOfLine(to, => editor.insertText(lastChar))(editor)
  atTheEndOfLine(from, => editor.backspace())(editor)

moveUp = (editor) ->
  editor.getCursorsOrderedByBufferPosition().map((c) -> c.getBufferRow()).forEach (row) -> moveLastChar(row + 1, row)(editor)

moveDown = (editor) ->
  editor.getCursorsOrderedByBufferPosition().map((c) -> c.getBufferRow()).forEach (row) -> moveLastChar(row, row - 1)(editor)

subscriptions =
  'editor:move-line-up'  : -> withActiveEditor collapsingHistory preservingSelections splittingMultilineSelections moveUp
  'editor:move-line-down': -> withActiveEditor collapsingHistory preservingSelections splittingMultilineSelections moveDown

module.exports =
  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', subscriptions

  deactivate: ->
    @subscriptions.dispose()
