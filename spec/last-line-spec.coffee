{lastLine} = require '../lib/atom-move-line.coffee'

using = (name, values, func) ->
  for value in values
    func.apply(this, value)
    jasmine.currentEnv_.currentSpec.description += ' (with "' + name + '" using ' + value + ')'

describe 'lastLine', ->
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

  using 'valid values', [[9, 10], [5, 6]], (prev, last) ->
    it 'should indicate last line', ->
      expect(lastLine(text[prev], text[last])).toBe true

  using 'invalid values', [[1, 2], [4, 5]], (prev, last) ->
    it 'should not pick middle lines', ->
      expect(lastLine(text[prev], text[last])).toBe false
    # expect(lastLine(text[2], text[3])).toBe false
    # expect(lastLine(text[6], text[7])).toBe false

  using 'valid values', [[0, 1], [3, 4]], (prev, last) ->
    it 'should not pick beginnings', ->
      expect(lastLine(text[prev], text[last])).toBe false

  using 'valid values', [[11, 12]], (prev, last) ->
    it 'should not pick punctiation', ->
      expect(lastLine(text[prev], text[last])).toBe false
