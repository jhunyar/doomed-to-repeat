function loadSprites()
  sprites = {}
  sprites.planets = {}  
    for i = 1, 25, 1 do
      table.insert(sprites.planets, love.graphics.newImage('sprites/planets/mars' .. i .. '.png'))
    end
  sprites.moons = {}
    for i = 1, 22, 1 do
      table.insert(sprites.moons, love.graphics.newImage('sprites/planets/moon' .. i .. '.png'))
    end
  sprites.player = love.graphics.newImage('sprites/ship-static.png')
  sprites.miniShip = love.graphics.newImage('sprites/miniship.png')
  sprites.shipStatic = love.graphics.newImage('sprites/ship-static.png')
  sprites.shipRotL = love.graphics.newImage('sprites/ship-rot-l.png')
  sprites.shipRotR = love.graphics.newImage('sprites/ship-rot-r.png')
  sprites.shipLeft = love.graphics.newImage('sprites/ship-left.png')
  sprites.shipLeftRotL = love.graphics.newImage('sprites/ship-left-rot-l.png')
  sprites.shipLeftRotR = love.graphics.newImage('sprites/ship-left-rot-r.png')
  sprites.shipRight = love.graphics.newImage('sprites/ship-right.png')
  sprites.shipRightRotL = love.graphics.newImage('sprites/ship-right-rot-l.png')
  sprites.shipRightRotR = love.graphics.newImage('sprites/ship-right-rot-r.png')
  sprites.shipFront = love.graphics.newImage('sprites/ship-front.png')
  sprites.shipFrontRotL = love.graphics.newImage('sprites/ship-front-rot-l.png')
  sprites.shipFrontRotR = love.graphics.newImage('sprites/ship-front-rot-r.png')
  sprites.shipRear = love.graphics.newImage('sprites/ship-rear.png')
  sprites.shipRearRotL = love.graphics.newImage('sprites/ship-rear-rot-l.png')
  sprites.shipRearRotR = love.graphics.newImage('sprites/ship-rear-rot-r.png')
  sprites.bullet = love.graphics.newImage('sprites/bullet3.png')
  sprites.enemy = love.graphics.newImage('sprites/enemy2.png')
  sprites.loot = love.graphics.newImage('sprites/bullet.png')
  sprites.planetAnim = love.graphics.newImage('sprites/planets/marssprites.png')
  sprites.planetLg = love.graphics.newImage('sprites/planets/mars-lg.png')
  sprites.background = love.graphics.newImage('sprites/bg.png')
  sprites.background:setWrap('repeat', 'repeat')
end