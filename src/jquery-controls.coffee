# Is there any reason to make the Controls and Values constructors available?
module.exports = do ( $ = window.jQuery ) ->
  require "./init.coffee"
  $.Controls = require "./controls.coffee"
  $.Values = require "./values.coffee"
  undefined
