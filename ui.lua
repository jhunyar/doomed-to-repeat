function drawHud()
  love.graphics.setFont(fontLarge)
  if gameState == 1 then
    love.graphics.print('Click anywhere to begin!', camX + 200, camY)
  end

  if showHUD == true then
    love.graphics.setFont(fontTiny)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print('Score: ' .. score, camX - 100, camY - 80)
    love.graphics.print('Ammo: ' .. player.ammo, camX + 60, camY - 80)
    love.graphics.print('Alarm: ' .. math.ceil(player.fear), camX + 60, camY + 80)
    vx, vy = player.body:getLinearVelocity()
    if vx < 0 then vx = vx * -1 end
    if vy < 0 then vy = vy * -1 end
    love.graphics.print('Velocity: ' .. math.floor(vx+vy), camX + -100, camY + 80)
    love.graphics.reset()
  end
end

function drawMinimap()
  if showMap == true then
    love.graphics.setColor(0.42,0.11,0.27,0.2)
    love.graphics.rectangle('fill', love.graphics:getWidth() -300, love.graphics:getHeight() - 300, mapw/100, maph/100)
    love.graphics.setColor(1,1,1)
    for i,p in ipairs(planets) do
      if p.discovered == true then
        local planetSize
        if p.size < 400 then
          planetSize = 4
        else
          planetSize = p.size/100/2
        end
        
        if p.owner == 'player' then
          love.graphics.setColor(0, 0.2, 1)
        elseif p.owner == 'enemy' then
          love.graphics.setColor(1, 0, 0)
        end

        love.graphics.circle('fill', love.graphics:getWidth() -300 + p.x/100, love.graphics.getHeight() - 300 + p.y/100, planetSize)
        love.graphics.setColor(1, 1, 1)
      end
    end

    love.graphics.draw(sprites.miniShip, love.graphics:getWidth() -300 + player.body:getX()/100, love.graphics.getHeight() - 300 + player.body:getY()/100, player_mouse_angle(), nil, nil, sprites.miniShip:getWidth()/2, sprites.miniShip:getHeight()/2)
  end
end