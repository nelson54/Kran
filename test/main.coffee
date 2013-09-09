component = require( '../src/main').component
system = require( '../src/main').system
entity = require( '../src/main').entity

describe 'Kran:', ->

  afterEach ->
    component.length = 0
    system.length = 0
    entity.length = 0

  describe 'component', ->

    comp = null

    beforeEach ->
      comp = component.new( -> @bar = 17 )

    it 'stores all components and their constructor function', ->
      func1 = () -> @x = 1
      func2 = () -> @y = 2

      comp1 = component.new(func1)
      comp2 = component.new(func2)

      component[comp1].should.equal func1
      component[comp2].should.equal func2

    it 'should delegate incrementing ids to component', ->
      comp2 = component.new(() -> foo)
      comp3 = component.new(() -> foo)
      comp.should.equal 0
      comp2.should.equal 1
      comp3.should.equal 2

    it 'can be instantiated', ->
      foo = new component[comp]()
      foo.bar.should.equal 17

    it 'keeps track of which systems includes it', ->
      comp2 = component.new(() -> foo)
      comp3 = component.new(() -> foo)
      sys = system.new({
        components: [comp, comp3]
      })
      component[comp].belongsTo[0].should.equal(sys)
      component[comp3].belongsTo[0].should.equal(sys)
      component[comp2].belongsTo.length.should.equal(0)

    it 'handles a single non-array component', ->
      sys = system.new({
        components: comp
      })
      component[comp].belongsTo[0].should.equal(sys)

  describe 'system', ->
    it 'makes it possible to add new systems', ->
      sys = system.new({})
      sys.should.equal 0
      sys = system.new({})
      sys.should.equal 1

    it 'can run systems', () ->
      spy = sinon.spy()
      spy()
      spy.should.have.been.called
      sys = system.new({ pre: spy })
      system.run(sys)

    it 'can run all systems at once', ->
      spy = sinon.spy()
      system.new { pre: spy }
      system.new { post: spy }
      system.runAll()
      spy.should.have.been.calledTwice

    it 'seperates systems into groups', ->
      spy = sinon.spy()
      spy2 = sinon.spy()
      system.new { pre: spy }
      system.new { pre: spy2, group: 'thsBgrp' }
      system.new { pre: spy2, group: 'thsBgrp' }

      system.runAll()
      system.thsBgrp.run()

      spy.should.have.been.calledOnce
      spy2.callCount.should.equal 4

  describe 'entity', ->
    it 'allows for creation of new entities', ->
      entity.new().should.equal 0
      entity.new().should.equal 1
      entity.new().should.equal 2

    it 'can add components to entities', ->
      spy = sinon.spy()
      comp = component.new(() -> @v = 1)
      sys = system.new {
        components: [comp],
        pre: spy
      }
      component[comp].belongsTo[0].should.equal(sys)
      ent = entity.new()
      entity[ent].add(comp)
      system[sys].entities.head.data.should.equal ent