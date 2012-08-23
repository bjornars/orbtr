exports = this.orbtr or= {}

AU = exports.AU = 149597870700

Vec = class exports.Vec
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


class exports.Orbiter
  constructor: (canvas, @div, @objects) ->
    @running = false
    @img = new Image()
    @img.src = 'planet.png'
    @time = 60*60 * 5 # seconds in day
    @sleep = 20
    @ticks = 20
    @total = 0
    @G = 6.674 * Math.pow(10, -11)
    @canvas =
      el: canvas
      scale: 2*AU
    @context = canvas.getContext('2d')

    $(window).resize =>
      @canvas.el.width = div.width()
      @canvas.el.height = div.height()
    $(window).resize()

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

  convert: (x, y) ->
    s = @canvas.scale or AU
    s *= 1.1
    factor = Math.min(@canvas.el.width, @canvas.el.height)
    s  /= factor
    [
      x / s + @canvas.el.width * 0.5
      y / s + @canvas.el.height * 0.5
    ]

  scale_canvas: (r) ->
    up_smooth = 0.95
    down_smooth = 0.98
    scale = Math.sqrt(r) * 2

    if @canvas.scale is 0
      @canvas.scale = scale
    else
      if scale > @canvas.scale
        smooth = up_smooth
      else
        smooth = down_smooth

      @canvas.scale = @canvas.scale * smooth  + scale * (1-smooth)

    $('#status-2').html "Scale: #{@canvas.scale / AU} AU"

  draw: =>
    @context.clearRect(0, 0, @canvas.el.width, @canvas.el.height)
    $('#status').html "#{@ticks} iterations per draw, #{@time / 3600} hours per iteration, #{1000 / @sleep} fps - running for #{@total / (3600*24*365)} years."

    radius = 0
    [x, y] = @convert 0, 0 # get center
    [r, _] = @convert AU, AU

    r -= x
    @context.strokeStyle = "#ddc"
    @context.font = "16pt arial"
    for each in [1, 5, 10, 50]
      @context.beginPath()
      @context.arc x, y, r * each, 0, Math.PI * 2, false
      @context.closePath()
      @context.stroke()

      @context.fillText "#{each} AU", x-20, y-r * each + 40

    @context.font = "12pt arial"
    for target in @objects
      [x, y] = [target.o.x, target.o.y]
      radius = Math.max(radius, x*x + y*y) if not target.no_scale

      [x, y] = @convert(x, y)
      @context.drawImage(
          @img
          x - target.size / 2
          y - target.size / 2
          target.size
          target.size
      )
      @context.fillText target.name, x-25, y-10 if target.size > 5

    @scale_canvas radius
