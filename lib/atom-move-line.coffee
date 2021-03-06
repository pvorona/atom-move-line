{CompositeDisposable} = require 'atom'

# TODO: autoinsert coma

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

trimTrailingWhitespace = (from, to) -> (editor) ->
  whitespaceRegex = /\s+$/
  [from, to].forEach (row) ->
    lineText = editor.lineTextForBufferRow(row)
    if whitespaceRegex.test(lineText)
      newLineText = lineText.replace(whitespaceRegex, "")
      rowBufferRange = editor.bufferRangeForBufferRow(row)
      editor.getBuffer().setTextInRange(rowBufferRange, newLineText)

move = (from, to) -> (editor) ->
  editor.getCursorsOrderedByBufferPosition()
    .map (c) -> c.getBufferRow()
    .forEach (row) ->
      trimTrailingWhitespace(row + from, row + to)(editor)
      moveLastChar(row + from, row + to)(editor)

subscriptions =
  'editor:move-line-up'  : -> withActiveEditor collapsingHistory preservingSelections splittingMultilineSelections move 1,  0
  'editor:move-line-down': -> withActiveEditor collapsingHistory preservingSelections splittingMultilineSelections move 0, -1

module.exports =
  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', subscriptions

  deactivate: ->
    @subscriptions.dispose()

  lastLine: lastLine
