fs = require "fs"

jQuery = window.jQuery
{ Controls, Values } = jQuery
sinon = window.sinon
{ expect } = window.chai

{ sameSelection } = require "./spec-utilities.coffee"

{ map
  some
  every
  slice
  filter
  reduce } = require "./array-generics.coffee"

{ CHECKABLE
  BUTTON
  TAGS
  RADIO
  CHECK } = require "./selectors.coffee"

first = ( arr ) -> arr[ 0 ]
last = ( arr ) -> arr[ arr.length - 1 ]

# htmlFiles = [
#   "./spec/html/values.html"
#   "./spec/html/mixed.html"
#   "./spec/html/validation.html"
#   "./spec/html/with-initial-state.html"
#   "./spec/html/with-labels.html"
# ]
#
trees = window.trees = do ->
  storage = {}
  byId: ( id ) ->
    if storage[id] then $.parseHTML( storage[id] )[0] else null
  addTree: ( htmlStr ) ->
    id = $( htmlStr ).attr "id"
    console.log id
    storage[id] = htmlStr

[
  fs.readFileSync "#{ __dirname }/html/values.html", "utf8"
  fs.readFileSync "#{ __dirname }/html/mixed.html", "utf8"
  fs.readFileSync "#{ __dirname }/html/validation.html", "utf8"
  fs.readFileSync "#{ __dirname }/html/with-initial-state.html", "utf8"
  fs.readFileSync "#{ __dirname }/html/with-labels.html", "utf8"
].map trees.addTree

describe "Control prototype methods", ->

  cSel = undefined
  jSel = undefined
  vSel = undefined
  qsa = undefined

  beforeEach ->
    root = trees.byId( "values" )
    jSel = $( root )
    cSel = $( root ).mixinControls()
    qsa = Element::querySelectorAll.bind( root )

  describe "@filter()", ->
    it "returns a Controls instance", ->
      expect( cSel.filter "button" ).to.be.instanceof Controls

    it "accepts a selector", ->
      flt = cSel.filter "button"
      btn = jSel.find "button"
      expect( sameSelection flt, btn ).to.equal true

    it "accepts an array of DOM elements", ->
      btn = qsa "button"
      flt = cSel.filter "button"
      expect( sameSelection flt, btn ).to.equal true

    it "accepts a function", ->
      flt = cSel.filter ->
        @tagName.toLowerCase() is "button"
      btn = qsa "button"
      expect( sameSelection flt, btn ).to.equal true

    it "accepts a jQuery selection", ->
      btn = jSel.find "button"
      flt = cSel.filter btn
      expect( sameSelection flt, btn ).to.equal true

    xit "accepts a Controls selection"

  describe "@not()", ->

    it "returns a Controls instance", ->
      expect( cSel.not "input" ).to.be.instanceof Controls

    it "accepts a selector", ->
      jNoInput = jSel.find( TAGS ).not "input"
      cNoInput = cSel.not "input"
      expect( sameSelection jNoInput, cNoInput ).to.equal true

    it "accepts an array of DOM elements", ->
      inputs = jSel.find( "input" ).get()
      cNoInput = cSel.not inputs
      hasAnInput = some cNoInput, ( el ) ->
        el.tagName.toLowerCase() is "input"
      expect( hasAnInput ).to.equal false

    it "accepts a function", ->
      cEmptyValue = cSel.not ->
        @value is ""
      vEmptyValue = filter qsa( TAGS ), ( el ) ->
        el.value isnt ""
      expect( sameSelection cEmptyValue, vEmptyValue ).to.equal true

    it "accepts a jQuery selection", ->
      jEmptyValue = jSel.filter ->
        @value is ""
      cNoEmptyValue = jSel.not jEmptyValue
      hasEmptyValues = some cNoEmptyValue, ( el ) ->
        @value is ""
      expect( hasEmptyValues ).to.equal false

    xit "accepts a Controls selection"

  describe "@reset()", ->
    it "resets disabled, required, and value to their resetState", ->
      root = trees.byId "initialState"
      els = $( root )
      ctls = $( root ).mixinControls()
      t1 = els.find( "#text1" )[0]
      t2 = els.find( "#text2" )[0]
      t3 = els.find( "#text3" )[0]
      t4 = els.find( "#text4" )[0]
      t1.value = ""
      t2.value = ""
      t2.required = false
      t3.value = ""
      t3.disabled = false
      t4.value = ""
      t4.required = false
      t4.disabled = false
      ctls.reset()
      expect( t1.value ).to.equal "one"
      expect( t2.value ).to.equal "two"
      expect( t2.required ).to.equal true
      expect( t3.value ).to.equal "three"
      expect( t3.disabled ).to.equal true
      expect( t4.value ).to.equal "four"
      expect( t4.required ).to.equal true
      expect( t4.disabled ).to.equal true

  describe "@clear()", ->
    it "clears values, checked, and selected", ->
      root = trees.byId "initialState"
      els = $( root )
      ctls = $( root ).mixinControls()
      ctls.clear()
      expect every ctls.filter( "[type='text']" ), ( el ) ->
        el.value is ""
      .to.equal true

      expect every ctls.filter( CHECKABLE ), ( el ) ->
        el.checked is false
      .to.equal true

      expect every ctls.asJQuery().find( "option" ), ( el ) ->
        el.selected is false
      .to.equal true

  describe "@propValues()", ->

  describe "@values()", ->

  describe "@check", ->
    it "checks all checkable inputs", ->
      cSel.check()

      expect every cSel.filter( CHECKABLE ), ( el ) ->
        el.checked is true
      .to.equal true

  describe "@uncheck", ->
    it "unchecks all checkable inputs", ->

      cSel.check()
      cSel.uncheck()

      expect every cSel.filter( CHECKABLE ), ( el ) ->
        $( el ).prop( "checked" ) is false
      .to.equal true

  describe "@require", ->
    it "makes all selected controls required", ->
      cSel.require()

      expect every cSel.not( "button" ), ( el ) ->
        el.required is true
      .to.equal true

  describe "@unrequire", ->
    it "makes all selected controls not required", ->
      cSel.require()

      expect every cSel.not( "button" ), ( el ) ->
        el.required is true
      .to.equal true

      cSel.unrequire()

      expect every cSel, ( el ) ->
        el.required is false
      .to.equal true


  describe "@disable", ->
    it "makes selected controls disabled", ->
      cSel.disable()
      expect every cSel.not( "button" ), ( el ) ->
        el.disabled is true
      .to.equal true


  describe "@enable", ->
    it "makes selected controls enabled", ->
      cSel.disable()
      expect every cSel.not( "button" ), ( el ) ->
        el.disabled is true
      .to.equal true

      cSel.enable()
      expect every cSel.not( "button" ), ( el ) ->
        el.disabled is false
      .to.equal true


  describe "@labels", ->
    it "selects the labels of the controls", ->
      root = trees.byId "with-labels"
      lbls = reduce root.querySelectorAll( "input" ), ( acc, el ) ->
        if el.labels
          [].push.apply acc, slice el.labels
        acc
      , []
      expect( sameSelection $.mixinControls( $( root ) ).labels(), lbls ).to.be.true


  describe "@valid", ->

    it "delegates to Controls.validateElement", ->
      stub = sinon.stub Controls, "validateElement"
      cSel.valid()
      expect( stub.called ).to.be.true
      stub.restore()

    it "returns true when each element passes Controls.validateElement", ->
      stub = sinon.stub Controls, "validateElement", -> true
      expect( cSel.valid() ).to.be.true
      expect( stub.callCount ).to.equal cSel.length
      stub.restore()

    it "returns false when any element fails Controls.validateElement", ->
      stub = sinon.stub Controls, "validateElement", -> false
      expect( cSel.valid() ).to.be.false
      expect( stub.callCount ).to.equal 1
      stub.restore()

  describe "@bindValidator", ->

describe "jQuery traversal methods", ->

  root = undefined
  ctls = undefined
  beforeEach ->
    root = trees.byId "values"
    ctls = $( root ).mixinControls()

  describe "mutating methods return jQuery", ->
    methods = [
      "add"
      "addBack"
      "andSelf"
      "children"
      "closest"
      "contents"
      "end"
      "find"
      "next"
      "nextAll"
      "nextUntil"
      "offsetParent"
      "parent"
      "parents"
      "parentsUntil"
      "prev"
      "prevAll"
      "prevUntil"
      "siblings"
    ]

    methods.forEach ( method ) ->
      it "returns jQuery from @#{ method }()", ->
        selection = ctls[method]()
        expect( selection ).to.be.instanceof jQuery
        expect( selection ).to.not.be instanceof Controls

    it "returns jQuery from @map()", ->
      mapResult = ctls.map ->
      expect( mapResult ).to.be.instanceof jQuery
      expect( mapResult ).to.not.be instanceof Controls

  describe "subset methods return Controls", ->

    methods = [
      "slice"
      "first"
      "last"
      "filter"
      "not"
      "eq"
    ]

    methods.forEach ( method ) ->
      it "returns Controls from @#{ method }()", ->
        expect( ctls[method]() ).to.be.instanceof Controls

  describe "each returns Controls", ->
    it "returns Controls from @each()", ->
      expect( ctls.each( -> ) ).to.be.instanceof Controls



if window?.mochaPhantomJS
  window.mochaPhantomJS.run()
else if mocha
  mocha.run()
else
  throw new Error "No Mocha!"