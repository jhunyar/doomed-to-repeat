sndShoot = love.audio.newSource('audio/bonk-2.wav', 'static')
sndDestroy = love.audio.newSource('audio/bonk-3.wav', 'static')
sndLaunch = love.audio.newSource('audio/lose-4.wav', 'static')
music = love.audio.newSource('audio/Vast Surroundings (LOOP).wav', 'stream')
ending = love.audio.newSource('audio/ending.ogg', 'stream')

love.audio.setEffect('reverb', {type = 'reverb'})

sndLaunch:setEffect('reverb')

sndShoot:setVolume(0.25)
sndDestroy:setVolume(0.5)
music:setVolume(0.15)
music:setLooping(true)
music:play()
ending:setVolume(0.5)