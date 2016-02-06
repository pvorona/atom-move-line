describe 'move-line', ->
  [editor, activationPromise, workspaceElement, textEditorElement] = []
  text =
    '''
      {
        "firstName": "Иван",
        "lastName": "Иванов",
        "address": {
            "streetAddress": "Московское ш., 101, кв.101",
            "city": "Ленинград",
            "postalCode": 101101
        },
        "phoneNumbers": [
            "812 123-1234",
            "916 123-4567"
        ]
      }
    '''

  dispatch = (command, callback) ->
    atom.commands.dispatch textEditorElement, command
    waitsForPromise -> activationPromise
    runs(callback)

  beforeEach ->
    waitsForPromise ->
      atom.workspace.open()

    runs ->
      workspaceElement = atom.views.getView(atom.workspace)
      editor = atom.workspace.getActiveTextEditor()
      textEditorElement = atom.views.getView(editor)
      activationPromise = atom.packages.activatePackage 'atom-move-line'
      editor.setText text

  it 'should swap comma', ->
    result =
      '''
        {
          "firstName": "Иван",
          "lastName": "Иванов",
          "address": {
              "streetAddress": "Московское ш., 101, кв.101",
              "city": "Ленинград",
              "postalCode": 101101
          },
          "phoneNumbers": [
              "916 123-4567",
              "812 123-1234"
          ]
        }
      '''
    editor.setCursorBufferPosition [10, 0]
    dispatch 'editor:move-line-up', ->
      expect(editor.getText()).toEqual result
