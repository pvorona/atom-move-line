{CompositeDisposable} = require 'atom'
{withActiveEditor, collapsingHistory, preservingSelections, splittingMultilineSelections, atTheEndOfLine} = require './functional-decorators.coffee'

# TODO: be ready for preceding/trailing spaces/tabs
# TODO: be ready for preceding/trailing comments (check grammars)
# TODO: autoinsert comma

# endsWithComma = /^\s*.*\s*(,)\s*$/
endsWithComma = /(^\s*.*\s*),(\s*$)/
endsWithComma1 = /(^\s*.*)(\s*$)/
declarationStart = /.*[{\[]\s*/
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
  toLineModified = toLine.replace(endsWithComma1, '$1,$2')
  console.log('toLine.replace(endsWithComma1, $1)', toLine.replace(endsWithComma1, '$1'));
  editor.setTextInBufferRange([[to, 0], [to, toLine.length]], toLineModified)
  # atTheEndOfLine(to, => editor.insertText(','))(editor)
  fromLineModified = fromLine.replace(endsWithComma, '$1$2')
  editor.setTextInBufferRange([[from, 0], [from, fromLine.length]], fromLineModified)

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
