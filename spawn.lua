function spawnLoot()
  loot = {}

  loot.x = math.random(0, mapw)
  loot.y = math.random(0, maph)
  loot.type = 'ammo'
  loot.claimed = false

  table.insert(loots, loot)
end