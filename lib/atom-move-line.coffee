{CompositeDisposable} = require 'atom'
{withActiveEditor, collapsingHistory, preservingSelections, splittingMultilineSelections, atTheEndOfLine} = require './functional-decorators.coffee'

# TODO: be ready for preceding/trailing spaces/tabs
# TODO: be ready for preceding/trailing comments (check grammars)
# TODO: autoinsert comma

endsWithComma = /^\s*.*\s*(,)\s*$/
declarationStart = /.*[{\[]/
# endsWithComma = /^\s*(["'`]?).*(\1)\s*(,)\s*$/

lastLine = (prevLine, lastLine) ->
  endsWithComma.test(prevLine) and not endsWithComma.test(lastLine)

declaration = (line) ->
  declarationStart.test line

shouldMoveComma = (from, to) ->
  lastLine(from, to) and not declaration(to)

moveLastChar = (from, to) -> (editor) ->
  [fromLine, toLine] = [editor.lineTextForBufferRow(from), editor.lineTextForBufferRow(to)]
  return unless shouldMoveComma(fromLine, toLine)
  lastChar = fromLine[fromLine.length - 1]
  atTheEndOfLine(to, => editor.insertText(lastChar))(editor)
  atTheEndOfLine(from, => editor.backspace())(editor)

moveUp = (editor) ->
  editor.getCursorsOrderedByBufferPosition()
    .map (c) -> c.getBufferRow()
    .forEach (row) -> moveLastChar(row + 1, row)(editor);

moveDown = (editor) ->
  editor.getCursorsOrderedByBufferPosition()
    .map (c) -> c.getBufferRow()
    .forEach (row) -> moveLastChar(row, row - 1)(editor)

subscriptions =
  'editor:move-line-up'  : -> withActiveEditor collapsingHistory preservingSelections splittingMultilineSelections moveUp
  'editor:move-line-down': -> withActiveEditor collapsingHistory preservingSelections splittingMultilineSelections moveDown

module.exports =
  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', subscriptions

  deactivate: ->
    @subscriptions.dispose()

  lastLine: lastLine
