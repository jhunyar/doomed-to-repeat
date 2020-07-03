function drawHud()
  love.graphics.setFont(fontLarge)
  if gameState == 1 then
    love.graphics.print('Click anywhere to begin!', camX + 200, camY)
  end

  if showHUD == true then
    local a = radToDeg(player_mouse_angle()) - radToDeg(player.body:getAngle())
    a = (a + 180) % 360-180

    love.graphics.setFont(fontTiny)
    love.graphics.setColor(0.5, 0.5, 0.5)
    -- love.graphics.print('Score: ' .. score, camX - 100, camY - 80)
    if player.warpReady == true then love.graphics.print('Warp Ready', camX - 100, camY - 100) end
    love.graphics.print('Sector: ' .. player.currentSector, camX - 100, camY - 80)
    love.graphics.print('Ammo: ' .. player.ammo, camX + 60, camY - 80)
    love.graphics.print('L.Damp: ' .. player.linearDampingStatus, camX + 60, camY + 80)
    vx, vy = player.body:getLinearVelocity()
    if vx < 0 then vx = vx * -1 end
    if vy < 0 then vy = vy * -1 end
    love.graphics.print('Velocity: ' .. math.floor(vx+vy), camX + -100, camY + 80)
    love.graphics.setColor(1, 1, 1)

    if player.scannerData[1] then
      love.graphics.printf(player.scannerData[1].data, 10, camY - 10, 200, 'left')
    end
  end
end

function drawMinimap()
  if showMap == true then
    love.graphics.setColor(0.42,0.11,0.27,0.2)
    love.graphics.rectangle('fill', love.graphics:getWidth() -510, love.graphics:getHeight() - 510, mapw/2000, maph/2000)
    love.graphics.setColor(1,1,1)
    for i,p in ipairs(planets) do
      if p.discovered == true then
        if p.owner == 'player' then
          love.graphics.setColor(0, 0.2, 1)
        elseif p.owner == 'enemy' then
          love.graphics.setColor(1, 0, 0)
        end

        love.graphics.circle('fill', love.graphics:getWidth() -510 + p.x/2000, love.graphics.getHeight() - 510 + p.y/2000, 4)
        love.graphics.setColor(1, 1, 1)
      end

      if p.moon == 1 and p.moonDiscovered == true then
        love.graphics.circle('fill', love.graphics.getWidth() -510 + p.moonX/2000, love.graphics.getHeight() - 510 + p.moonY/2000, 2) 
      end
    end

    love.graphics.draw(sprites.miniShip, love.graphics:getWidth() -510 + player.body:getX()/2000, love.graphics.getHeight() - 510 + player.body:getY()/2000, player.body:getAngle(), nil, nil, sprites.miniShip:getWidth()/4, sprites.miniShip:getHeight()/4)
  end
end