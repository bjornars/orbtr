class Vec
  constructor: (@x, @y, @z) ->

  iadd: (v)  ->
    @x += v.x
    @y += v.y
    @z += v.z
    
  sub: (v)  ->
    new Vec(
      @x - v.x
      @y - v.y
      @z - v.z
    )
    
  imul: (v)  ->
    @x *= v
    @y *= v
    @z *= v
    
  mul: (v)  ->
    new Vec(
      @x * v
      @y * v
      @z * v
    )
    
  neg: ->
    new Vec(-@x, -@y, -@z)
    
  len: ->
    Math.sqrt(@x * @x + @y * @y + @z * @z)

  inormalize: ->
    len = @len()
    @x /= len
    @y /= len
    @z /= len
   
data = [
  name: 'sun'
  m: 2.0 * Math.pow(10, 30)
  v: new Vec(0, 0, 0)
  o: new Vec(0, 0, 0)
,
  name: 'earth'
  m: 6.0 * Math.pow(10, 24)
  v: new Vec(0, 30*Math.pow(10, 3), 0)
  o: new Vec(149*Math.pow(10, 9), 0, 0)
]

class Orbiter
  constructor: (@context) ->
    @objects = data
    @running = true
    @img = new Image()
    @img.src = 'planet.png'
    @time = 3600 * 24 # seconds in day
    @G = 6.674 * Math.pow(10, -11)
  
  calculate: ->
    # calc all acting forces for all objects
    for target in @objects
      fs = new Vec(0, 0, 0)
      for source in @objects
        if target isnt source
        
          r = source.o.sub(target.o)
          r_len = r.len()
          r_len *= r_len
          f_mag = @G * target.m * source.m / r_len
          f_dir = r.mul(f_mag / r.len())
          fs.iadd(f_dir)

      target.pending = fs

    # apply impulses
    for target in @objects
      target.v.iadd(target.pending.mul(@time / target.m))

    # apply velocity
    for target in @objects
      target.o.iadd(target.v.mul(@time))
    null

  tick: (number) ->
    while number--
      @calculate()
    null

  start: =>
    @tick 1000
    @draw()
    setTimeout(@start, 100) if @running

  stop: ->
    @running = false

  toggle: ->
    if not @running
      @running = true
      @start()
    else
      @running = false

  draw: =>
    scale = Math.pow(10, 11)
    convert1 = (x) ->
      ((x / scale) + 1) * 250
    convert2 = (x, y) ->
      [convert1(x), convert1(y)]

    $('canvas')[0].width = $('canvas')[0].width

    for target in @objects
      coords = convert2(target.o.x, target.o.y)
      console.log [target.name, coords[0], coords[1]]
      @context.drawImage(@img, coords[0], coords[1], 25, 25)
    
$ ->
  orbiter = new Orbiter $('canvas')[0].getContext('2d')
  orbiter.start()
  $('canvas').click ->
    orbiter.toggle()
