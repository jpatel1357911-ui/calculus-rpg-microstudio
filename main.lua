-- CALCULUS RPG - ULTIMATE EDITION
-- Advanced gameplay with economy, boss mechanics, perks, and progression systems

-- Game configuration
CONFIG = {
  MAX_LEVEL = 50,
  PRESTIGE_MULTIPLIER = 1.5,
  SHOP_ITEMS_COUNT = 8,
  BOSS_HEALTH_MULTIPLIER = 2.5,
  CRIT_CHANCE = 0.15,
  CRIT_MULTIPLIER = 1.8
}

-- Difficulty settings
DIFFICULTY = {
  EASY = {multiplier = 0.7, timeLimit = 15, name = "EASY"},
  NORMAL = {multiplier = 1.0, timeLimit = 10, name = "NORMAL"},
  HARD = {multiplier = 1.5, timeLimit = 7, name = "HARD"},
  INSANE = {multiplier = 2.5, timeLimit = 5, name = "INSANE"}
}

-- Perks system
PERKS = {
  {id = "crit_master", name = "Crit Master", cost = 500, effect = "Increase critical hit chance by 50%"},
  {id = "exp_boost", name = "EXP Boost", cost = 300, effect = "Gain +20% more experience"},
  {id = "mana_regen", name = "Mana Regen", cost = 400, effect = "Regenerate 2 mana per turn"},
  {id = "hp_recovery", name = "HP Recovery", cost = 250, effect = "Heal 5 HP when answering correctly"},
  {id = "damage_boost", name = "Damage Boost", cost = 350, effect = "Increase attack power by 20%"},
  {id = "defense_plus", name = "Defense+", cost = 300, effect = "Increase defense by 2"},
  {id = "streak_multiplier", name = "Streak Master", cost = 600, effect = "Streak multiplier +0.15x"},
  {id = "money_maker", name = "Money Maker", cost = 450, effect = "Earn 50% more gold"}
}

-- Shop items
SHOP_ITEMS = {
  {id = "health_potion", name = "Health Potion", cost = 50, type = "consumable", effect = "Restore 30 HP"},
  {id = "mana_potion", name = "Mana Potion", cost = 40, type = "consumable", effect = "Restore 20 Mana"},
  {id = "revive_scroll", name = "Revive Scroll", cost = 200, type = "consumable", effect = "Revive with 50% HP"},
  {id = "stat_stone_atk", name = "Attack Stone", cost = 100, type = "permanent", effect = "+2 Attack"},
  {id = "stat_stone_def", name = "Defense Stone", cost = 100, type = "permanent", effect = "+1 Defense"},
  {id = "stat_stone_hp", name = "Health Stone", cost = 80, type = "permanent", effect = "+10 Max HP"},
  {id = "lucky_coin", name = "Lucky Coin", cost = 150, type = "passive", effect = "+10% Luck"},
  {id = "ancient_tome", name = "Ancient Tome", cost = 300, type = "permanent", effect = "+15% all XP"}
}

-- Boss encounter system
BOSSES = {
  {name = "Derivative Overlord", level = 5, isBoss = true, color = {1, 0.2, 0.2}},
  {name = "Integral Tyrant", level = 10, isBoss = true, color = {1, 0.5, 0.2}},
  {name = "Limit Architect", level = 15, isBoss = true, color = {0.7, 0.2, 1}},
  {name = "Calculus God", level = 20, isBoss = true, color = {0.2, 1, 1}}
}

-- Player class - ENHANCED
Player = {}
Player.__index = Player

function Player.new(name, difficulty)
  local self = setmetatable({}, Player)
  self.name = name
  self.difficulty = difficulty or DIFFICULTY.NORMAL
  self.level = 1
  self.exp = 0
  self.maxExp = 100
  self.hp = 100
  self.maxHP = 100
  self.mana = 50
  self.maxMana = 50
  self.attack = 10
  self.defense = 5
  self.gold = 0
  self.streak = 0
  self.maxStreak = 0
  self.consecutiveWins = 0
  self.totalDamageDealt = 0
  self.totalDamageReceived = 0
  self.questsCompleted = 0
  self.prestige = 0  -- Prestige level for new game+
  self.x = 200
  self.y = 240
  
  -- Equipment slots
  self.equipment = {
    weapon = nil,
    armor = nil,
    accessory = nil
  }
  
  -- Inventory management
  self.inventory = {}
  self.maxInventory = 20
  
  -- Spells with cooldowns
  self.spells = {
    {name = "Derivative Bolt", cost = 15, damage = 20, description = "d/dx attack!", cooldown = 0, maxCooldown = 0},
    {name = "Integral Shield", cost = 20, defense = 10, description = "∫ protection", cooldown = 0, maxCooldown = 2},
    {name = "Limit Break", cost = 25, damage = 35, description = "→ limit!", cooldown = 0, maxCooldown = 3},
    {name = "Chain Rule", cost = 30, damage = 45, description = "Complex derivative", cooldown = 0, maxCooldown = 4},
    {name = "Taylor Series", cost = 35, damage = 60, description = "Infinite power", cooldown = 0, maxCooldown = 5}
  }
  
  -- Perks purchased
  self.perks = {}
  
  -- Achievements
  self.achievements = {
    firstVictory = false,
    streak5 = false,
    streak10 = false,
    level5 = false,
    level10 = false,
    level25 = false,
    level50 = false,
    defeatBoss = false,
    defeatAllBosses = false,
    collectorSettle = false,
    moneyMaker = false,
    speedRunner = false,
    unkillable = false,
    prestigeMaster = false
  }
  
  return self
end

function Player:takeDamage(amount)
  self.hp = math.max(0, self.hp - amount)
  self.totalDamageReceived = self.totalDamageReceived + amount
  return self.hp == 0
end

function Player:heal(amount)
  self.hp = math.min(self.maxHP, self.hp + amount)
end

function Player:gainExp(amount, multiplier)
  multiplier = multiplier or 1.0
  
  -- Apply perks
  if self:hasPerk("exp_boost") then
    multiplier = multiplier * 1.2
  end
  if self:hasPerk("ancient_tome") then
    multiplier = multiplier * 1.15
  end
  
  local totalExp = math.floor(amount * multiplier)
  self.exp = self.exp + totalExp
  
  while self.exp >= self.maxExp do
    self:levelUp()
  end
end

function Player:levelUp()
  self.level = self.level + 1
  self.exp = self.exp - self.maxExp
  self.maxExp = math.floor(self.maxExp * 1.2)
  self.maxHP = self.maxHP + 20
  self.hp = self.maxHP
  self.maxMana = self.maxMana + 10
  self.mana = self.maxMana
  self.attack = self.attack + 3
  self.defense = self.defense + 1
  
  if self.level == 5 then self.achievements.level5 = true end
  if self.level == 10 then self.achievements.level10 = true end
  if self.level == 25 then self.achievements.level25 = true end
  if self.level == 50 then self.achievements.level50 = true end
end

function Player:useMana(amount)
  if self.mana >= amount then
    self.mana = self.mana - amount
    return true
  end
  return false
end

function Player:restoreMana(amount)
  self.mana = math.min(self.maxMana, self.mana + amount)
end

function Player:addStreak()
  self.streak = self.streak + 1
  if self.streak > self.maxStreak then
    self.maxStreak = self.streak
  end
  if self.streak >= 5 then self.achievements.streak5 = true end
  if self.streak >= 10 then self.achievements.streak10 = true end
end

function Player:resetStreak()
  self.streak = 0
end

function Player:addItem(itemId)
  if #self.inventory < self.maxInventory then
    table.insert(self.inventory, itemId)
    return true
  end
  return false
end

function Player:hasPerk(perkId)
  for _, perk in ipairs(self.perks) do
    if perk == perkId then return true end
  end
  return false
end

function Player:buyPerk(perkId)
  if self:hasPerk(perkId) then return false end
  for _, perk in ipairs(PERKS) do
    if perk.id == perkId and self.gold >= perk.cost then
      self.gold = self.gold - perk.cost
      table.insert(self.perks, perkId)
      return true
    end
  end
  return false
end

function Player:prestige()
  if self.level < 10 then return false end
  self.prestige = self.prestige + 1
  self.level = 1
  self.exp = 0
  self.maxExp = 100
  self.hp = 100
  self.maxHP = 100
  self.mana = 50
  self.maxMana = 50
  self.attack = 10 + (self.prestige * 2)
  self.defense = 5 + (self.prestige * 1)
  self.gold = 0
  self.streak = 0
  self.consecutiveWins = 0
  self.achievements.prestigeMaster = true
  return true
end

function Player:applyPerksBonus()
  if self:hasPerk("damage_boost") then
    self.attack = self.attack * 1.2
  end
  if self:hasPerk("defense_plus") then
    self.defense = self.defense + 2
  end
end

-- Enemy class - ENHANCED
Enemy = {}
Enemy.__index = Enemy

function Enemy.new(name, level, color, isBoss)
  local self = setmetatable({}, Enemy)
  self.name = name
  self.level = level
  self.isBoss = isBoss or false
  
  -- Boss scaling
  if self.isBoss then
    self.hp = (50 + (level * 25)) * CONFIG.BOSS_HEALTH_MULTIPLIER
  else
    self.hp = 30 + (level * 15)
  end
  
  self.maxHP = self.hp
  self.attack = 5 + (level * 2)
  self.defense = 2 + (level * 1)
  self.expReward = 25 * level * (isBoss and 3 or 1)
  self.goldReward = 10 * level * (isBoss and 2 or 1)
  self.x = 600
  self.y = 240
  self.color = color or {0.8, 0.2, 0.2}
  self.problems = self:generateProblems()
  self.currentProblem = 1
  self.phase = 1
  self.maxPhase = isBoss and 3 or 1
  return self
end

function Enemy:generateProblems()
  local problems = {
    -- Tier 1: Easy
    {q = "d/dx(x²)", a = "2x", d = 1},
    {q = "d/dx(3x)", a = "3", d = 1},
    {q = "∫3 dx", a = "3x", d = 1},
    {q = "d/dx(5)", a = "0", d = 1},
    
    -- Tier 2: Medium
    {q = "d/dx(x³)", a = "3x2", d = 2},
    {q = "d/dx(sin x)", a = "cos(x)", d = 2},
    {q = "d/dx(e^x)", a = "ex", d = 2},
    {q = "∫2x dx", a = "x2", d = 2},
    {q = "∫cos(x) dx", a = "sin(x)", d = 2},
    {q = "d/dx(x²+3x)", a = "2x+3", d = 2},
    
    -- Tier 3: Hard
    {q = "d/dx(ln x)", a = "1/x", d = 3},
    {q = "lim(x→0) sin(x)/x", a = "1", d = 3},
    {q = "d/dx(x⁴-3x²)", a = "4x3-6x", d = 3},
    {q = "d/dx(x·sin x)", a = "sin(x)+x·cos(x)", d = 3},
    {q = "∫sin(x) dx", a = "-cos(x)", d = 3},
    {q = "d/dx(1/x)", a = "-1/x2", d = 3},
    
    -- Tier 4: Expert
    {q = "d/dx(tan x)", a = "sec2(x)", d = 4},
    {q = "∫e^x dx", a = "ex", d = 4},
    {q = "d/dx(x^x)", a = "x^x(1+ln x)", d = 4},
    {q = "∫1/(1+x²) dx", a = "arctan(x)", d = 4},
  }
  return problems
end

function Enemy:getRandomProblem()
  local filtered = {}
  local diffLevel = math.min(self.level, 4)
  for _, p in ipairs(self.problems) do
    if p.d <= diffLevel then
      table.insert(filtered, p)
    end
  end
  if #filtered == 0 then filtered = self.problems end
  return filtered[math.random(1, #filtered)]
end

function Enemy:takeDamage(amount)
  self.hp = math.max(0, self.hp - amount)
  return self.hp <= 0
end

-- Battle system - ENHANCED
Battle = {}
Battle.__index = Battle

function Battle.new(player, enemy)
  local self = setmetatable({}, Battle)
  self.player = player
  self.enemy = enemy
  self.state = "player_turn"
  self.turn = 0
  self.message = "Answer a question to attack!"
  self.messageTimer = 0
  self.inputBuffer = ""
  self.currentProblem = enemy:getRandomProblem()
  self.answerResult = nil
  self.enemyTurnDelay = 0
  self.turnCount = 0
  self.totalDamage = 0
  self.comboMultiplier = 1.0
  self.timeRemaining = 10
  self.maxTime = 10
  return self
end

function Battle:askQuestion()
  self.currentProblem = self.enemy:getRandomProblem()
  self.inputBuffer = ""
  self.state = "answering_question"
  self.maxTime = self.player.difficulty.timeLimit
  self.timeRemaining = self.maxTime
  self.message = "Answer quickly!"
  self.messageTimer = 600
end

function Battle:playerAttack()
  if self.inputBuffer == "" then
    self.message = "Enter an answer!"
    self.messageTimer = 60
    return
  end
  
  local answer = self.inputBuffer:gsub("%s+", ""):lower()
  local correctAnswer = self.currentProblem.a:gsub("%s+", ""):lower()
  
  if answer == correctAnswer then
    self.player:addStreak()
    self.comboMultiplier = 1.0 + (self.player.streak * 0.1)
    
    local baseDamage = self.player.attack + math.random(1, 8)
    
    -- Critical hit system
    local isCrit = false
    local critChance = CONFIG.CRIT_CHANCE
    if self.player:hasPerk("crit_master") then
      critChance = critChance * 1.5
    end
    if math.random() < critChance then
      isCrit = true
      baseDamage = math.floor(baseDamage * CONFIG.CRIT_MULTIPLIER)
    end
    
    local damage = math.floor(baseDamage * self.comboMultiplier)
    
    local critText = isCrit and " CRIT!" or ""
    self.message = "✓ CORRECT! ×" .. string.format("%.1f", self.comboMultiplier) .. " +" .. damage .. " DMG" .. critText
    self.answerResult = true
    self.enemy:takeDamage(damage)
    self.totalDamage = self.totalDamage + damage
    self.messageTimer = 120
    
    -- HP Recovery perk
    if self.player:hasPerk("hp_recovery") then
      self.player:heal(5)
    end
    
    -- Mana Regen perk
    if self.player:hasPerk("mana_regen") then
      self.player:restoreMana(2)
    end
    
    if self.enemy.hp <= 0 then
      self:win()
      return
    else
      self.enemyTurnDelay = 120
      self.state = "enemy_turn"
    end
  else
    self.player:resetStreak()
    self.comboMultiplier = 1.0
    self.message = "✗ WRONG! Ans: " .. self.currentProblem.a
    self.answerResult = false
    self.messageTimer = 120
    self.enemyTurnDelay = 180
    self.state = "enemy_turn"
  end
  
  self.inputBuffer = ""
end

function Battle:useSpell(spellIndex)
  local spell = self.player.spells[spellIndex]
  if not spell then return end
  
  if spell.cooldown > 0 then
    self.message = spell.name .. " is on cooldown! (" .. spell.cooldown .. ")"
    self.messageTimer = 60
    return
  end
  
  if not self.player:useMana(spell.cost) then
    self.message = "Not enough mana! Need " .. spell.cost
    self.messageTimer = 60
    return
  end
  
  local baseDamage = spell.damage
  local damage = math.floor(baseDamage + math.random(1, 15))
  self.message = spell.name .. " +" .. damage .. " DMG"
  self.enemy:takeDamage(damage)
  self.totalDamage = self.totalDamage + damage
  self.messageTimer = 120
  self.player:resetStreak()
  spell.cooldown = spell.maxCooldown
  
  if self.enemy.hp <= 0 then
    self:win()
    return
  end
  
  self.enemyTurnDelay = 120
  self.state = "enemy_turn"
end

function Battle:defend()
  self.player.defense = self.player.defense + 5
  self.message = "Defending! Defense +5"
  self.messageTimer = 120
  self.enemyTurnDelay = 120
  self.state = "enemy_turn"
  self.player:resetStreak()
end

function Battle:enemyAttack()
  if self.enemyTurnDelay > 0 then
    self.enemyTurnDelay = self.enemyTurnDelay - 1
    
    -- Reduce cooldowns
    for _, spell in ipairs(self.player.spells) do
      if spell.cooldown > 0 then
        spell.cooldown = spell.cooldown - 1
      end
    end
    
    return
  end
  
  local damage = self.enemy.attack + math.random(1, 6)
  damage = math.max(1, damage - self.player.defense)
  self.message = self.enemy.name .. " attacks! -" .. damage .. " HP"
  self.player:takeDamage(damage)
  self.messageTimer = 120
  
  if self.player.hp <= 0 then
    self:lose()
  else
    self.player.defense = 5
    self.state = "player_turn"
  end
end

function Battle:win()
  self.player.achievements.firstVictory = true
  self.player.consecutiveWins = self.player.consecutiveWins + 1
  self.player.questsCompleted = self.player.questsCompleted + 1
  
  if self.enemy.isBoss then
    self.player.achievements.defeatBoss = true
  end
  
  local hpBonus = math.floor((self.player.hp / self.player.maxHP) * 0.5)
  local totalExp = self.enemy.expReward + hpBonus
  
  self.player.gold = self.player.gold + self.enemy.goldReward
  if self.player:hasPerk("money_maker") then
    self.player.gold = self.player.gold + math.floor(self.enemy.goldReward * 0.5)
  end
  
  self.player:gainExp(totalExp, self.player.difficulty.multiplier)
  
  self.state = "victory"
  self.message = "VICTORY! +" .. totalExp .. " EXP, +" .. self.enemy.goldReward .. " GOLD"
  self.messageTimer = 180
end

function Battle:lose()
  self.player.consecutiveWins = 0
  self.player.gold = math.floor(self.player.gold / 2)
  self.state = "defeat"
  self.message = "DEFEAT! Lost half your gold"
  self.messageTimer = 180
end

-- Game Manager - ENHANCED
game = {
  state = "menu",
  currentMenu = "main",
  player = nil,
  battle = nil,
  inputBuffer = "",
  selectedEnemy = 1,
  selectedDifficulty = 2,
  selectedShopItem = 1,
  selectedPerk = 1,
  gameStats = {
    totalBattles = 0,
    totalWins = 0,
    totalLosses = 0,
    totalGoldEarned = 0,
    totalExpGained = 0,
    highestLevel = 0,
    highestStreak = 0
  },
  enemies = {
    {name = "Derivative Dragon", level = 1, color = {0.8, 0.2, 0.2}},
    {name = "Integral Imp", level = 2, color = {0.8, 0.5, 0.2}},
    {name = "Limit Leviathan", level = 3, color = {0.5, 0.2, 0.8}},
    {name = "Chain Rule Chimera", level = 4, color = {0.2, 0.5, 0.8}},
    {name = "Calculus Colossus", level = 5, color = {0.2, 0.8, 0.2}}
  },
  difficulties = {
    {name = "EASY", mod = 0.7},
    {name = "NORMAL", mod = 1.0},
    {name = "HARD", mod = 1.5},
    {name = "INSANE", mod = 2.5}
  }
}

function init()
  screen:setClip(0, 0, 800, 480)
end

function update(dt)
  if game.battle then
    game.battle.messageTimer = math.max(0, game.battle.messageTimer - 1)
    
    if game.battle.state == "enemy_turn" then
      game.battle:enemyAttack()
    end
    
    if game.battle.state == "answering_question" then
      game.battle.timeRemaining = math.max(0, game.battle.timeRemaining - 1)
      if game.battle.timeRemaining <= 0 then
        game.battle.message = "TIME'S UP!"
        game.battle.messageTimer = 60
        game.battle.answerResult = false
        game.battle.player:resetStreak()
        game.battle.enemyTurnDelay = 180
        game.battle.state = "enemy_turn"
      end
    end
  end
end

function draw()
  if game.state == "menu" then
    drawMenu()
  elseif game.state == "game" then
    drawGame()
  elseif game.state == "battle" then
    drawBattle()
  end
end

function drawMenu()
  screen:clear(0.05, 0.05, 0.1)
  
  if game.currentMenu == "main" then
    drawMainMenu()
  elseif game.currentMenu == "new_game" then
    drawNewGameMenu()
  elseif game.currentMenu == "difficulty" then
    drawDifficultyMenu()
  elseif game.currentMenu == "select_enemy" then
    drawSelectEnemyMenu()
  elseif game.currentMenu == "select_boss" then
    drawSelectBossMenu()
  elseif game.currentMenu == "shop" then
    drawShopMenu()
  elseif game.currentMenu == "perks" then
    drawPerksMenu()
  elseif game.currentMenu == "stats" then
    drawStatsMenu()
  elseif game.currentMenu == "about" then
    drawAboutMenu()
  end
end

function drawMainMenu()
  screen:setColor(0.2, 1, 0.8)
  screen:setFont("arial", 3)
  screen:print("CALCULUS RPG", 0.5, 0.9, 1)
  
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.2)
  screen:print("1. New Game", 0.5, 0.75, 1)
  screen:print("2. Shop", 0.5, 0.65, 1)
  screen:print("3. Perks", 0.5, 0.55, 1)
  screen:print("4. Statistics", 0.5, 0.45, 1)
  screen:print("5. About", 0.5, 0.35, 1)
  screen:print("6. Quit", 0.5, 0.25, 1)
  
  screen:setColor(0.5, 1, 0.8)
  screen:setFont("arial", 0.9)
  screen:print("Master calculus through ULTIMATE battles!", 0.5, 0.1, 1)
end

function drawDifficultyMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.8)
  screen:print("SELECT DIFFICULTY", 0.5, 0.9, 1)
  
  screen:setFont("arial", 1.1)
  for i, diff in ipairs(game.difficulties) do
    if i == game.selectedDifficulty then
      screen:setColor(1, 1, 0.3)
      screen:print("> " .. diff.name .. " ×" .. diff.mod .. " <", 0.5, 0.75 - (i-1) * 0.12, 1)
    else
      screen:setColor(0.6, 0.6, 0.6)
      screen:print(diff.name .. " ×" .. diff.mod, 0.5, 0.75 - (i-1) * 0.12, 1)
    end
  end
  
  screen:setColor(0.5, 0.5, 0.5)
  screen:setFont("arial", 0.8)
  screen:print("UP/DOWN select, ENTER confirm", 0.5, 0.1, 1)
end

function drawNewGameMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.5)
  screen:print("Enter your name:", 0.5, 0.7, 1)
  
  screen:setFont("arial", 1.2)
  screen:print(game.inputBuffer .. "_", 0.5, 0.55, 1)
  
  screen:setColor(0.5, 0.5, 0.5)
  screen:setFont("arial", 0.8)
  screen:print("Press ENTER to continue", 0.5, 0.3, 1)
end

function drawSelectEnemyMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.5)
  screen:print("SELECT ENEMY", 0.5, 0.9, 1)
  
  screen:setFont("arial", 1)
  for i, enemy in ipairs(game.enemies) do
    if i == game.selectedEnemy then
      screen:setColor(1, 1, 0.3)
      screen:print("> " .. i .. ". " .. enemy.name .. " (Lv" .. enemy.level .. ") <", 0.5, 0.75 - (i-1) * 0.1, 1)
    else
      screen:setColor(0.5, 0.5, 0.5)
      screen:print(i .. ". " .. enemy.name .. " (Lv" .. enemy.level .. ")", 0.5, 0.75 - (i-1) * 0.1, 1)
    end
  end
  
  screen:setColor(0.8, 0.8, 0.8)
  screen:setFont("arial", 0.8)
  screen:print("B - Boss Battle | UP/DOWN select | ENTER battle", 0.5, 0.15, 1)
end

function drawSelectBossMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.5)
  screen:print("SELECT BOSS", 0.5, 0.9, 1)
  
  screen:setFont("arial", 1)
  for i, boss in ipairs(BOSSES) do
    if i == game.selectedEnemy then
      screen:setColor(1, 1, 0.3)
      screen:print("> " .. i .. ". " .. boss.name .. " (Lv" .. boss.level .. ") <", 0.5, 0.75 - (i-1) * 0.1, 1)
    else
      screen:setColor(0.5, 0.5, 0.5)
      screen:print(i .. ". " .. boss.name .. " (Lv" .. boss.level .. ")", 0.5, 0.75 - (i-1) * 0.1, 1)
    end
  end
  
  screen:setColor(0.8, 0.8, 0.8)
  screen:setFont("arial", 0.8)
  screen:print("UP/DOWN select | ENTER battle | ESC back", 0.5, 0.15, 1)
end

function drawShopMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.5)
  screen:print("SHOP - Gold: " .. game.player.gold, 0.5, 0.95, 1)
  
  screen:setFont("arial", 0.9)
  for i = 1, math.min(5, #SHOP_ITEMS) do
    local item = SHOP_ITEMS[i]
    if i == game.selectedShopItem then
      screen:setColor(1, 1, 0.3)
      screen:print("> " .. item.name .. " (" .. item.cost .. "G) <", 0.5, 0.80 - (i-1) * 0.12, 1)
    else
      screen:setColor(0.5, 0.5, 0.5)
      screen:print(item.name .. " (" .. item.cost .. "G)", 0.5, 0.80 - (i-1) * 0.12, 1)
    end
  end
  
  screen:setColor(0.8, 0.8, 0.8)
  screen:setFont("arial", 0.8)
  screen:print("UP/DOWN select | ENTER buy | ESC back", 0.5, 0.15, 1)
end

function drawPerksMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.5)
  screen:print("PERKS - Gold: " .. game.player.gold, 0.5, 0.95, 1)
  
  screen:setFont("arial", 0.9)
  for i = 1, math.min(5, #PERKS) do
    local perk = PERKS[i]
    local status = game.player:hasPerk(perk.id) and " [OWNED]" or " (" .. perk.cost .. "G)"
    if i == game.selectedPerk then
      screen:setColor(1, 1, 0.3)
      screen:print("> " .. perk.name .. status .. " <", 0.5, 0.80 - (i-1) * 0.12, 1)
    else
      screen:setColor(0.5, 0.5, 0.5)
      screen:print(perk.name .. status, 0.5, 0.80 - (i-1) * 0.12, 1)
    end
  end
  
  screen:setColor(0.8, 0.8, 0.8)
  screen:setFont("arial", 0.8)
  screen:print("UP/DOWN select | ENTER buy | ESC back", 0.5, 0.15, 1)
end

function drawStatsMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.5)
  screen:print("STATISTICS", 0.5, 0.9, 1)
  
  screen:setColor(0.8, 1, 0.8)
  screen:setFont("arial", 0.9)
  screen:print("Total Battles: " .. game.gameStats.totalBattles, 0.5, 0.8, 1)
  screen:print("Wins: " .. game.gameStats.totalWins .. " | Losses: " .. game.gameStats.totalLosses, 0.5, 0.75, 1)
  screen:print("Highest Level: " .. game.gameStats.highestLevel, 0.5, 0.7, 1)
  screen:print("Highest Streak: " .. game.gameStats.highestStreak, 0.5, 0.65, 1)
  screen:print("Total Gold: " .. game.gameStats.totalGoldEarned, 0.5, 0.6, 1)
  
  screen:setColor(0.5, 0.5, 0.5)
  screen:setFont("arial", 0.8)
  screen:print("Press ESC to return", 0.5, 0.2, 1)
end

function drawAboutMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.5)
  screen:print("ULTIMATE CALCULUS RPG", 0.5, 0.9, 1)
  
  screen:setColor(0.8, 0.8, 1)
  screen:setFont("arial", 0.8)
  screen:print("Features: Perks, Shop, Bosses, Prestige, Cooldowns", 0.5, 0.8, 1)
  screen:print("Combo system, Critical hits, 4 difficulties", 0.5, 0.75, 1)
  screen:print("20+ unique calculus problems", 0.5, 0.70, 1)
  
  screen:setColor(0.5, 0.5, 0.5)
  screen:setFont("arial", 0.8)
  screen:print("Press ESC to return", 0.5, 0.2, 1)
end

function drawGame()
  screen:clear(0.08, 0.08, 0.12)
  
  screen:setColor(0.2, 1, 0.8)
  screen:setFont("arial", 1.1)
  screen:print(game.player.name .. " - Level " .. game.player.level .. " (P" .. game.player.prestige .. ")", 0.05, 0.95, 0)
  
  screen:setColor(1, 0.3, 0.3)
  screen:print("HP: " .. game.player.hp .. "/" .. game.player.maxHP, 0.05, 0.90, 0)
  
  screen:setColor(0.3, 0.7, 1)
  screen:print("Mana: " .. game.player.mana .. "/" .. game.player.maxMana, 0.05, 0.85, 0)
  
  screen:setColor(1, 1, 0.3)
  screen:print("EXP: " .. game.player.exp .. "/" .. game.player.maxExp, 0.05, 0.80, 0)
  
  screen:setColor(1, 0.8, 0.2)
  screen:print("Gold: " .. game.player.gold, 0.05, 0.75, 0)
  
  screen:setColor(0.8, 1, 0.8)
  screen:print("Streak: " .. game.player.streak .. " | Best: " .. game.player.maxStreak, 0.05, 0.70, 0)
  
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.2)
  screen:print("1. BATTLE", 0.5, 0.65, 1)
  screen:print("2. BOSS", 0.5, 0.55, 1)
  screen:print("3. SHOP", 0.5, 0.45, 1)
  screen:print("4. REST (10G)", 0.5, 0.35, 1)
  screen:print("5. PRESTIGE", 0.5, 0.25, 1)
end

function drawBattle()
  screen:clear(0.12, 0.08, 0.15)
  
  screen:setColor(0.2, 0.9, 0.2)
  screen:fillRect(0.1, 0.35, 0.12, 0.2)
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 0.9)
  screen:print(game.player.name, 0.1, 0.3, 0.5)
  
  screen:setColor(game.battle.enemy.color[1], game.battle.enemy.color[2], game.battle.enemy.color[3])
  screen:fillRect(0.78, 0.35, 0.12, 0.2)
  screen:setColor(1, 1, 1)
  screen:print(game.battle.enemy.name, 0.78, 0.3, 0.5)
  
  drawHPBar(0.16, 0.62, game.battle.player.hp, game.battle.player.maxHP, 0.2, 0.9, 0.2)
  drawHPBar(0.84, 0.62, game.battle.enemy.hp, game.battle.enemy.maxHP, 0.8, 0.2, 0.2)
  
  screen:setColor(0.15, 0.15, 0.2)
  screen:fillRect(0, 0, 1, 0.25)
  
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 0.85)
  
  if game.battle.state == "answering_question" then
    screen:print("Q: " .. game.battle.currentProblem.q, 0.5, 0.18, 1)
    screen:setFont("arial", 0.8)
    screen:print("Answer: " .. game.battle.inputBuffer .. "_", 0.5, 0.10, 1)
    screen:setColor(1, 1, 0.3)
    screen:print("Time: " .. math.ceil(game.battle.timeRemaining / 60) .. "s", 0.5, 0.03, 1)
  elseif game.battle.state == "player_turn" then
    screen:print("1.Answer | 2.Spell1 | 3.Spell2 | 4.Spell3 | 5.Defend", 0.5, 0.16, 1)
    if game.battle.messageTimer > 0 then
      if game.battle.answerResult == true then
        screen:setColor(0.2, 1, 0.2)
      elseif game.battle.answerResult == false then
        screen:setColor(1, 0.2, 0.2)
      else
        screen:setColor(1, 1, 0.3)
      end
      screen:print(game.battle.message, 0.5, 0.07, 1)
    end
  elseif game.battle.state == "victory" then
    screen:setColor(0.2, 1, 0.2)
    screen:print(game.battle.message, 0.5, 0.12, 1)
    screen:setColor(0.5, 0.5, 0.5)
    screen:setFont("arial", 0.7)
    screen:print("Press ENTER to continue", 0.5, 0.03, 1)
  elseif game.battle.state == "defeat" then
    screen:setColor(1, 0.2, 0.2)
    screen:print(game.battle.message, 0.5, 0.12, 1)
    screen:setColor(0.5, 0.5, 0.5)
    screen:setFont("arial", 0.7)
    screen:print("Press ENTER to continue", 0.5, 0.03, 1)
  else
    screen:setColor(1, 1, 0.3)
    screen:print(game.battle.message, 0.5, 0.12, 1)
  end
end

function drawHPBar(x, y, hp, maxHP, r, g, b)
  local barWidth = 0.14
  local barHeight = 0.04
  
  screen:setColor(0.2, 0.2, 0.2)
  screen:fillRect(x - barWidth/2, y - barHeight/2, barWidth, barHeight)
  
  screen:setColor(r, g, b)
  screen:fillRect(x - barWidth/2, y - barHeight/2, barWidth * (hp / maxHP), barHeight)
  
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 0.65)
  screen:print(math.floor(hp) .. "/" .. math.floor(maxHP), x, y + 0.06, 1)
end

function keyboard(key)
  if game.state == "menu" then
    handleMenuKeyboard(key)
  elseif game.state == "game" then
    handleGameKeyboard(key)
  elseif game.state == "battle" then
    handleBattleKeyboard(key)
  end
end

function handleMenuKeyboard(key)
  if game.currentMenu == "main" then
    if key == "1" then game.currentMenu = "new_game"; game.inputBuffer = ""
    elseif key == "2" then game.currentMenu = "shop"
    elseif key == "3" then game.currentMenu = "perks"
    elseif key == "4" then game.currentMenu = "stats"
    elseif key == "5" then game.currentMenu = "about"
    elseif key == "6" then os.exit() end
  elseif game.currentMenu == "new_game" then
    if key == "return" then
      if game.inputBuffer ~= "" then game.currentMenu = "difficulty" end
    elseif key == "backspace" then
      game.inputBuffer = game.inputBuffer:sub(1, -2)
    elseif key == "escape" then game.currentMenu = "main"
    elseif #key == 1 and #game.inputBuffer < 20 then
      game.inputBuffer = game.inputBuffer .. key
    end
  elseif game.currentMenu == "difficulty" then
    if key == "up" then game.selectedDifficulty = math.max(1, game.selectedDifficulty - 1)
    elseif key == "down" then game.selectedDifficulty = math.min(#game.difficulties, game.selectedDifficulty + 1)
    elseif key == "return" then
      local diff = DIFFICULTY.NORMAL
      if game.selectedDifficulty == 1 then diff = DIFFICULTY.EASY
      elseif game.selectedDifficulty == 3 then diff = DIFFICULTY.HARD
      elseif game.selectedDifficulty == 4 then diff = DIFFICULTY.INSANE end
      game.player = Player.new(game.inputBuffer, diff)
      game.currentMenu = "select_enemy"
    elseif key == "escape" then game.currentMenu = "new_game" end
  elseif game.currentMenu == "select_enemy" then
    if key == "up" then game.selectedEnemy = math.max(1, game.selectedEnemy - 1)
    elseif key == "down" then game.selectedEnemy = math.min(#game.enemies, game.selectedEnemy + 1)
    elseif key == "b" then game.currentMenu = "select_boss"; game.selectedEnemy = 1
    elseif key == "return" then
      local e = game.enemies[game.selectedEnemy]
      local enemy = Enemy.new(e.name, e.level, e.color, false)
      game.battle = Battle.new(game.player, enemy)
      game.battle:askQuestion()
      game.state = "battle"
    elseif key == "escape" then game.currentMenu = "main"; game.player = nil end
  elseif game.currentMenu == "select_boss" then
    if key == "up" then game.selectedEnemy = math.max(1, game.selectedEnemy - 1)
    elseif key == "down" then game.selectedEnemy = math.min(#BOSSES, game.selectedEnemy + 1)
    elseif key == "return" then
      local b = BOSSES[game.selectedEnemy]
      local boss = Enemy.new(b.name, b.level, b.color, true)
      game.battle = Battle.new(game.player, boss)
      game.battle:askQuestion()
      game.state = "battle"
    elseif key == "escape" then game.currentMenu = "select_enemy" end
  elseif game.currentMenu == "shop" then
    if key == "up" then game.selectedShopItem = math.max(1, game.selectedShopItem - 1)
    elseif key == "down" then game.selectedShopItem = math.min(#SHOP_ITEMS, game.selectedShopItem + 1)
    elseif key == "escape" then game.currentMenu = "main" end
  elseif game.currentMenu == "perks" then
    if key == "up" then game.selectedPerk = math.max(1, game.selectedPerk - 1)
    elseif key == "down" then game.selectedPerk = math.min(#PERKS, game.selectedPerk + 1)
    elseif key == "escape" then game.currentMenu = "main" end
  elseif game.currentMenu == "stats" or game.currentMenu == "about" then
    if key == "escape" then game.currentMenu = "main" end
  end
end

function handleGameKeyboard(key)
  if key == "1" then game.currentMenu = "select_enemy"; game.state = "menu"
  elseif key == "2" then game.currentMenu = "select_boss"; game.state = "menu"
  elseif key == "3" then game.currentMenu = "shop"; game.state = "menu"
  elseif key == "4" then
    if game.player.gold >= 10 then
      game.player.hp = game.player.maxHP
      game.player.mana = game.player.maxMana
      game.player.gold = game.player.gold - 10
      game.player:resetStreak()
    end
  elseif key == "5" then
    if game.player.level >= 10 then
      game.player:prestige()
    end
  end
end

function handleBattleKeyboard(key)
  if game.battle.state == "answering_question" then
    if key == "return" then game.battle:playerAttack()
    elseif key == "escape" then game.state = "game"; game.battle = nil
    elseif key == "backspace" then game.battle.inputBuffer = game.battle.inputBuffer:sub(1, -2)
    elseif #key == 1 and #game.battle.inputBuffer < 30 then
      game.battle.inputBuffer = game.battle.inputBuffer .. key
    end
  elseif game.battle.state == "player_turn" then
    if key == "1" then game.battle:askQuestion()
    elseif key == "2" then game.battle:useSpell(1)
    elseif key == "3" then game.battle:useSpell(2)
    elseif key == "4" then game.battle:useSpell(3)
    elseif key == "5" then game.battle:defend()
    elseif key == "escape" then
      if math.random(1, 100) > 40 then
        game.state = "game"; game.battle = nil
      else
        game.battle.state = "enemy_turn"
      end
    end
  elseif game.battle.state == "victory" or game.battle.state == "defeat" then
    if key == "return" or key == "space" then
      game.gameStats.totalBattles = game.gameStats.totalBattles + 1
      if game.battle.state == "victory" then
        game.gameStats.totalWins = game.gameStats.totalWins + 1
      else
        game.gameStats.totalLosses = game.gameStats.totalLosses + 1
      end
      if game.player.level > game.gameStats.highestLevel then
        game.gameStats.highestLevel = game.player.level
      end
      if game.player.maxStreak > game.gameStats.highestStreak then
        game.gameStats.highestStreak = game.player.maxStreak
      end
      game.state = "game"; game.battle = nil
    end
  end
end
