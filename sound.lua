sndShoot = love.sound.newSoundData('audio/shot.ogg')
sndDestroy = love.sound.newSoundData('audio/explosion-short.ogg')
explosionLong = love.sound.newSoundData('audio/explosion-long.ogg')
sndLaunch = love.sound.newSoundData('audio/lose-4.wav')
sndThrust = love.sound.newSoundData('audio/thrust.ogg')
sndThrustStart = love.sound.newSoundData('audio/thrust-start.ogg')
sndThrustHold = love.sound.newSoundData('audio/thrust-hold.ogg')
sndThrustEnd = love.sound.newSoundData('audio/thrust-release.ogg')

function playSound(sd)
  love.audio.newSource(sd, 'static'):play()
end