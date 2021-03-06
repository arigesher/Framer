describe "LayerStates", ->
	
	describe "Events", ->

		beforeEach ->
			@layer = new Layer()
			@layer.states.add 'a', x: 100, y: 100
			@layer.states.add 'b', x: 200, y: 200

		it "should emit willSwitch when switching", (done) ->
			
			test = (previous, current, states) =>
				previous.should.equal 'default'
				current.should.equal 'a'
				@layer.states.state.should.equal 'default'
				done()

			@layer.states.on 'willSwitch', test
			@layer.states.switchInstant 'a'

		it "should emit didSwitch when switching", (done) ->
			
			test = (previous, current, states) =>
				previous.should.equal 'default'
				current.should.equal 'a'
				@layer.states.state.should.equal 'a'
				done()

			@layer.states.on 'didSwitch', test
			@layer.states.switchInstant 'a'


	describe "Defaults", ->
		
		it "should set defaults", ->

			layer = new Layer
			layer.states.add "test", {x:123}
			layer.states.switch "test"

			layer.states._animation.options.curve.should.equal Framer.Defaults.Animation.curve

			Framer.Defaults.Animation =
				curve: "spring(1, 2, 3)"

			layer = new Layer
			layer.states.add "test", {x:456}
			layer.states.switch "test"

			layer.states._animation.options.curve.should.equal "spring(1, 2, 3)"

			Framer.resetDefaults()



	describe "Switch", ->

		it "should switch instant", ->

			layer = new Layer
			layer.states.add
				stateA: {x:123}
				stateB: {y:123}

			layer.states.switchInstant "stateA"
			layer.states.current.should.equal "stateA"
			layer.x.should.equal 123

			layer.states.switchInstant "stateB"
			layer.states.current.should.equal "stateB"
			layer.y.should.equal 123
