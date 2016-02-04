{lastLine} = require '../lib/atom-move-line.coffee'

describe 'atom-move-line', ->
  text = [
   '{'                                                        #0
     '"firstName": "Иван",'                                   #1
     '"lastName": "Иванов",'                                  #2
     '"address": {'                                           #3
        '"streetAddress": "Московское ш., 101, кв.101",'      #4
        '"city": "Ленинград",'                                #5
        '"postalCode": "101101"'                              #6
     '},'                                                     #7
     '"phoneNumbers": ['                                      #8
        '"812 123-1234",'                                     #9
         '"916 123-4567"'                                     #10
      ']'                                                     #11
    '}'                                                       #12
  ]

  it 'should not be loaded on start', ->
    expect(atom.packages.loadedPackages['atom-move-line']).toBeUndefined()
  #
  # it 'should load on "editor:move-line-up"', ->
  #   expect(atom.packages.loadedPackages['atom-move-line']).toBeDefined()
  #
  # it 'should load on "editor:move-line-down"', ->
  #   expect(atom.packages.loadedPackages['atom-move-line']).toBeDefined()

  describe 'lastLine', ->
    it 'should indicate last line', ->
      expect(lastLine(text[9], text[10])).toBe true
      expect(lastLine(text[5], text[6])).toBe true

    it 'should not pick middle lines', ->
      expect(lastLine(text[1], text[2])).toBe false
      expect(lastLine(text[4], text[5])).toBe false
      # expect(lastLine(text[2], text[3])).toBe false

    it 'should not pick punctiation', ->
      expect(lastLine(text[11], text[12])).toBe false
