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

module.exports = {withActiveEditor, collapsingHistory, preservingSelections, splittingMultilineSelections, atTheEndOfLine}
