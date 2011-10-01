racer = require 'racer'
modelHelper = require './modelHelper'
Dom = require './Dom'
View = require './View'
History = require './History'

Page = -> return
Page:: =
  render: (ctx) ->
    @view.render @model, ctx
  redirect: (url) ->

exports.createApp = (appModule) ->
  appExports = appModule.exports
  # Expose Racer and Derby methods on the application module
  racer.util.merge appExports, racer
  appExports.view = view = new View

  routes = []
  appExports.get = (pattern, callback) -> routes.push [pattern, callback]
  history = new History routes, page = new Page

  model = view.model = racer.model
  dom = view.dom = new Dom model, appExports, history
  modelHelper.init model, dom, view
  appExports.ready = (fn) -> racer.onready = -> fn model
  page.view = view
  page.model = model

  # "{{templates}}" is replaced with an array of templates by loader
  view.make name, template  for name, template of "{{templates}}"

  appModule.exports = (idCount, paths, partialIds, aliases, depths, modelBundle, modelEvents, domEvents) ->
    view._idCount = idCount
    view._paths = paths
    view._partialIds = partialIds
    view._aliases = aliases
    view._depths = depths
    racer.init modelBundle
    model.__events.set modelEvents
    dom.init domEvents
    return appExports

  return appExports
