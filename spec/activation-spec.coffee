xdescribe 'activation', ->
  [editor, activationPromise, workspaceElement, textEditorElement] = []

  dispatch = (command, callback) ->
    atom.commands.dispatch textEditorElement, command
    waitsForPromise -> activationPromise
    runs(callback)

  beforeEach ->
    runs ->
      workspaceElement = atom.views.getView(atom.workspace)
      editor = atom.workspace.getActiveTextEditor()
      textEditorElement = atom.views.getView(editor)
      activationPromise = atom.packages.activatePackage 'atom-move-line'

  it 'should not be loaded on start', ->
    expect(atom.packages.getActivePackage('atom-move-line')).toBe(undefined)

  it 'should load on "editor:move-line-up"', ->
    dispatch 'editor:move-line-up', -> expect(atom.packages.getActivePackage('atom-move-line')).not.toBe(undefined)

  it 'should load on "editor:move-line-down"', ->
    dispatch 'editor:move-line-down', -> expect(atom.packages.getActivePackage('atom-move-line')).not.toBe(undefined)
