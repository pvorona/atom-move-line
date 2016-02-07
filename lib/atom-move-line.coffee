{CompositeDisposable} = require 'atom'
{withActiveEditor, collapsingHistory, preservingSelections, splittingMultilineSelections, atTheEndOfLine} = require './decorators.coffee'

# TODO: be ready for trailing spaces/tabs
# TODO: be ready for trailing comments (check grammars)
# TODO: autoinsert comma

endsWithComma = /^\s*.*\s*(,)\s*$/
# endsWithComma = /^\s*(["'`]?).*(\1)\s*(,)\s*$/

lastLine = (prevLine, lastLine) ->
  prevLine.match(endsWithComma)? and not lastLine.match(endsWithComma)?
  # prevLine.endsWith(',') and not lastLine.endsWith(',')

declaration = (line) ->
  ['{', '['].some (terminator) -> line.endsWith terminator

shouldMoveComma = (from, to) ->
  lastLine(from, to) or declaration(to)

moveLastChar = (from, to) -> (editor) ->
  [fromLine, toLine] = [editor.lineTextForBufferRow(from), editor.lineTextForBufferRow(to)]
  # return unless lastLine(fromLine, toLine) and not declaration(toLine)
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
