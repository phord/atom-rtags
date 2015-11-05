_ = require 'underscore-plus'
{Disposable, CompositeDisposable, Emitter} = require 'atom'
#escapeHelper = require '../escape-helper'

class Result
  @create: (result) ->
    if result?.matches?.length then new Result(result) else null

  constructor: (result) ->
    _.extend(this, result)

class FindOptions
  constructor: ->
    @emitter = new Emitter
    @findPattern = 'token'
    @replacePattern = ''
    @pathsPattern = ''
    @useRegex = false
    @caseSensitive = false
    @wholeWord = false
    @inCurrentSelection = false
  onDidChange: (callback) ->
  onDidChangeReplacePattern: (callback) ->

module.exports =
class AtomRtagsReferencesModel
  constructor: ->
    @emitter = new Emitter
    @findOptions = new FindOptions

  setModel: (@model) ->
    @results = {}
    @paths = []
    {res, @pathCount, @matchCount, @symbolName, symbolLength} = @model
    filePathInsertedIndex = 0
    for filePath, v of res
      matches = []
      for [r, c, lineText] in v
        lineTextOffset = 0
        matchText = lineText.substring c+1, c+symbolLength+1
        range = [[r,c], [r,c+symbolLength+1]]
        matches.push {lineText, lineTextOffset, matchText, range}
      result = Result.create({matches})
      @paths.push filePath
      @results[filePath] = result
      @emitter.emit 'did-add-result', {filePath, result, filePathInsertedIndex}
      filePathInsertedIndex++
    @emitter.emit 'did-finish-searching', @getResultsSummary()

  onDidClear: (callback) ->
    @emitter.on 'did-clear', callback

  onDidClearSearchState: (callback) ->
    @emitter.on 'did-clear-search-state', callback

  onDidClearReplacementState: (callback) ->
    @emitter.on 'did-clear-replacement-state', callback

  onDidSearchPaths: (callback) ->
    @emitter.on 'did-search-paths', callback

  onDidErrorForPath: (callback) ->
    @emitter.on 'did-error-for-path', callback

  onDidStartSearching: (callback) ->
    @emitter.on 'did-start-searching', callback

  onDidCancelSearching: (callback) ->
    @emitter.on 'did-cancel-searching', callback

  onDidFinishSearching: (callback) ->
    @emitter.on 'did-finish-searching', callback

  onDidAddResult: (callback) ->
    @emitter.on 'did-add-result', callback

  onDidRemoveResult: (callback) ->
    @emitter.on 'did-remove-result', callback

  getResultsSummary: ->
    res = { findPattern:@symbolName,
    @pathCount, @matchCount,
    replacePattern:'',
    searchErrors:null, replacedPathCount:null,
    replacementCount:null, replacementErrors:null }
    #console.log 'getResultsSummary', res
    res

  setActive: (isActive) ->
    @active = isActive

  getActive: -> @active

  getFindOptions: ->
    @findOptions

  getPathCount: ->
    @pathCount

  getMatchCount: ->
    @matchCount

  getPaths: ->
    @paths

  getResult: (filePath) ->
    @results[filePath]