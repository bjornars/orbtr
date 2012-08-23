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

  str: ->
    "Vec(#{@x}, #{@y}, #{@z})"

data = [
   name: 'sun'
   m: 2.0 * Math.pow(10, 30)
   v: new Vec(0, 0, 0)
   o: new Vec(0, 0, 0)
   size: 50
 ,
  name: 'earth'
  m: 6.0 * Math.pow(10, 24)
  v: new Vec(0, 30*Math.pow(10, 3), 0)
  o: new Vec(149*Math.pow(10, 9), 0, 0)
  size: 10
,
  name: 'earth'
  m: 6.0 * Math.pow(10, 24)
  v: new Vec(0, 30*Math.pow(10, 3), 0)
  o: new Vec(152*Math.pow(10, 9), 0, 0)
  size: 10
,
  name: 'earth'
  m: 6.0 * Math.pow(10, 24)
  v: new Vec(0, 30*Math.pow(10, 3), 0)
  o: new Vec(155*Math.pow(10, 9), 0, 0)
  size: 10
,
  name: 'earth'
  m: 6.0 * Math.pow(10, 27)
  v: new Vec(0, -30*Math.pow(10, 3), 0)
  o: new Vec(-159*Math.pow(10, 9), 0, 0)
  size: 25
,
  name: 'moon'
  m: 7.3 * Math.pow(10, 22)
  v: new Vec(0, 30*Math.pow(10, 3) + 1000, 0)
  o: new Vec(149*Math.pow(10, 9) + 385000000, 0, 0)
  size: 5
,
]

class Orbiter
  constructor: (@context) ->
    @objects = data
    @running = false
    @img = new Image()
    @img.src = 'planet.png'
    @time = 60*60 * 5 # seconds in day
    @sleep = 20
    @ticks = 10
    @total = 0
    @G = 6.674 * Math.pow(10, -11)
    @context.font = "12pt Arial"

  calculate: ->
    # calc all acting forces for all objects
    for target in @objects
      fs = new Vec(0, 0, 0)
      for source in @objects
        if target isnt source

          r = source.o.sub(target.o)
          r_len = r.len()
          r_len2 = r_len * r_len
          f_mag = @G * target.m * source.m / r_len2
          f_dir = r.mul(f_mag / r_len)
          if not f_mag is f_dir.len()
            console.log ['BORK', f_mag, f_dir.len()]
          # console.log "#{target.name} - #{source.name} is #{r_len}m away, giving #{f_mag}N of force"
          fs.iadd(f_dir)

      target.pending = fs

    for target in @objects
      # apply impulses
      new_v = target.pending.mul(@time / target.m)
      # console.log "#{target.name} - poking #{target.m}kg with #{target.pending.len()}N over #{@time}s, increasing v with #{new_v.len()}"
      target.v.iadd(new_v)

      # apply velocity
      # console.log "#{target.name} - moving by #{target.v.str()} over #{@time}"
      target.o.iadd(target.v.mul(@time))
    @total += @time

  tick: (number) ->
    while number--
      @calculate()
    null

  start: =>
    @tick @ticks
    @draw()
    setTimeout(@start, @sleep) if @running

  stop: ->
    @running = false

  toggle: (e)->
    if e.button == 1
      @tick 1
      @draw()

    else if not @running
      @running = true
      @start()
    else
      @running = false

  draw: =>
    scale = Math.pow(10, 11) * 2
    convert1 = (x) ->
      ((x / scale) + 1) * 250
    convert2 = (x, y) ->
      [convert1(x), convert1(y)]

    $('canvas')[0].width = $('canvas')[0].width
    $('#status').html "#{@ticks} iterations per draw, #{@time / 3600} hours per iteration, #{1000 / @sleep} fps - running for #{@total / (3600*24*365)} years."

    for target in @objects
      coords = convert2(target.o.x, target.o.y)
      @context.drawImage(@img, coords[0] - target.size / 2, coords[1] - target.size / 2, target.size, target.size)

$ ->
  orbiter = new Orbiter $('canvas')[0].getContext('2d')
  orbiter.start()
  $('canvas').click (e) ->
    orbiter.toggle(e)
