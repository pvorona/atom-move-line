fdescribe 'editor:move-line-down', ->
  [text, editor, activationPromise, workspaceElement, textEditorElement] = []
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
    runs callback

  beforeEach ->
    waitsForPromise ->
      atom.workspace.open()

    runs ->
      workspaceElement = atom.views.getView(atom.workspace)
      editor = atom.workspace.getActiveTextEditor()
      textEditorElement = atom.views.getView(editor)
      activationPromise = atom.packages.activatePackage 'atom-move-line'
      editor.setText text

  check = (description, command, {row}, result) ->
    it 'should ' + description, ->
      editor.setCursorBufferPosition [row, 0]
      dispatch command, ->
        expect(editor.getText()).toEqual result

  check 'swap comma when moving to the last line in array', 'editor:move-line-down', {row: 9},
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

  check 'swap comma when moving to the last line in object', 'editor:move-line-down', {row: 5},
    '''
      {
        "firstName": "Иван",
        "lastName": "Иванов",
        "address": {
          "streetAddress": "Московское ш., 101, кв.101",
          "postalCode": 101101,
          "city": "Ленинград"
        },
        "phoneNumbers": [
          "812 123-1234",
          "916 123-4567"
        ]
      }
    '''

  check 'not change text when moving not on last lines of object', 'editor:move-line-down', {row: 1},
    '''
        {
          "lastName": "Иванов",
          "firstName": "Иван",
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

  check 'not change text when moving not on last lines of array', 'editor:move-line-down', {row: 4},
    '''
      {
        "firstName": "Иван",
        "lastName": "Иванов",
        "address": {
          "city": "Ленинград",
          "streetAddress": "Московское ш., 101, кв.101",
          "postalCode": 101101
        },
        "phoneNumbers": [
          "812 123-1234",
          "916 123-4567"
        ]
      }
    '''

  check 'not change text when moving through declarations', 'editor:move-line-down', {row: 3},
    '''
      {
        "firstName": "Иван",
        "lastName": "Иванов",
          "streetAddress": "Московское ш., 101, кв.101",
        "address": {
          "city": "Ленинград",
          "postalCode": 101101
        },
        "phoneNumbers": [
          "812 123-1234",
          "916 123-4567"
        ]
      }
    '''

  check 'not change text when moving through declarations', 'editor:move-line-down', {row: 3},
    '''
      {
        "firstName": "Иван",
        "lastName": "Иванов",
          "streetAddress": "Московское ш., 101, кв.101",
        "address": {
          "city": "Ленинград",
          "postalCode": 101101
        },
        "phoneNumbers": [
          "812 123-1234",
          "916 123-4567"
        ]
      }
    '''
