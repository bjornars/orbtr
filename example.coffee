AU = orbtr.AU
Vec = orbtr.Vec
Orbiter = orbtr.Orbiter

data = [
   name: 'sun'
   m: 2.0 * Math.pow(10, 30)
   v: new Vec(0, 0, 0)
   o: new Vec(0, 0, 0)
   size: 50
 ,
  name: 'earth'
  m: 6.0 * Math.pow(10, 24)
  v: new Vec(0, 30000, 0)
  o: new Vec(AU, 0, 0)
  size: 15
,
  name: 'mars'
  m: 6.4 * Math.pow(10, 24)
  v: new Vec(0, 24000, 0)
  o: new Vec(1.53*AU, 0, 0)
  size: 15
,
  name: 'jupiter'
  m: 6.0 * Math.pow(10, 24)
  v: new Vec(0, 13000, 0)
  o: new Vec(5.5 * AU, 0, 0)
  size: 25
,
  name:  'comet'
  m: 50000
  v: new Vec(42000, 41000, 0)
  o: new Vec(AU*0.44, 0, 0)
  size: 5
,
  name:  'comet'
  m: 50000
  v: new Vec(42000, 42000, 0)
  o: new Vec(AU*0.43, 0, 0)
  size: 5
,
  name:  'comet'
  m: 50000
  v: new Vec(42000, 43000, 0)
  o: new Vec(AU*0.42, 0, 0)
  size: 5
,
  name:  'comet'
  m: 50000
  v: new Vec(42000, 44000, 0)
  o: new Vec(AU*0.41, 0, 0)
  size: 5
,
  name:  'comet'
  m: 50000
  v: new Vec(42000, 45000, 0)
  o: new Vec(AU*0.40, 0, 0)
  size: 5
,
  name:  'comet'
  m: 50000
  v: new Vec(42000, 46000, 0)
  o: new Vec(AU*0.39, 0, 0)
  size: 5
,
  name:  'comet'
  m: 50000
  v: new Vec(42000, 47000, 0)
  o: new Vec(AU*0.38, 0, 0)
  size: 5
,
  name:  'big comet'
  m: 5000000
  v: new Vec(-5000, 27000, 0)
  o: new Vec(AU*1.38, 0, 0)
  size: 8
,
  name: 'moon'
  m: 7.3 * Math.pow(10, 22)
  v: new Vec(0, 30000 + 1000, 0)
  o: new Vec(AU + 385000000, 0, 0)
  size: 6
,
]

$ ->
  orbiter = new Orbiter $('canvas')[0], $('#container'), data
  orbiter.start()
  $('canvas').click (e) ->
    orbiter.toggle(e)
