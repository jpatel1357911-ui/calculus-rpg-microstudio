-- Calculus RPG for MicroStudio
-- A math-themed RPG adventure with graphics

-- Game states
GAME_STATE = "menu"
CURRENT_MENU = "main"

-- Player class
Player = {}
Player.__index = Player

function Player.new(name)
  local self = setmetatable({}, Player)
  self.name = name
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
  self.x = 200
  self.y = 240
  
  self.spells = {
    {name = "Derivative Bolt", cost = 15, damage = 20, description = "Find the derivative!"},
    {name = "Integral Shield", cost = 20, defense = 10, description = "Integrate protection"},
    {name = "Limit Break", cost = 25, damage = 35, description = "Push to the limit!"}
  }
  return self
end

function Player:takeDamage(amount)
  self.hp = math.max(0, self.hp - amount)
  return self.hp == 0
end

function Player:heal(amount)
  self.hp = math.min(self.maxHP, self.hp + amount)
end

function Player:gainExp(amount)
  self.exp = self.exp + amount
  if self.exp >= self.maxExp then
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

-- Enemy class
Enemy = {}
Enemy.__index = Enemy

function Enemy.new(name, level, color)
  local self = setmetatable({}, Enemy)
  self.name = name
  self.level = level
  self.hp = 30 + (level * 15)
  self.maxHP = self.hp
  self.attack = 5 + (level * 2)
  self.defense = 2 + (level * 1)
  self.expReward = 25 * level
  self.goldReward = 10 * level
  self.x = 600
  self.y = 240
  self.color = color or {0.8, 0.2, 0.2}
  self.problems = self:generateProblems()
  self.currentProblem = 1
  return self
end

function Enemy:generateProblems()
  local problems = {
    {question = "Derivative of x^3?", answer = "3x2", explanation = "d/dx(x^3) = 3x^2"},
    {question = "Derivative of sin(x)?", answer = "cos(x)", explanation = "d/dx(sin x) = cos x"},
    {question = "Derivative of e^x?", answer = "ex", explanation = "d/dx(e^x) = e^x"},
    {question = "Integral of 2x?", answer = "x2", explanation = "∫2x dx = x^2 + C"},
    {question = "Limit: sin(x)/x as x->0?", answer = "1", explanation = "Fundamental limit = 1"},
    {question = "Derivative of ln(x)?", answer = "1/x", explanation = "d/dx(ln x) = 1/x"},
    {question = "Integral of cos(x)?", answer = "sin(x)", explanation = "∫cos x dx = sin x + C"},
    {question = "d/dx(x^4-3x^2)?", answer = "4x3-6x", explanation = "4x^3 - 6x"},
  }
  return problems
end

function Enemy:getCurrentProblem()
  return self.problems[self.currentProblem]
end

function Enemy:nextProblem()
  self.currentProblem = self.currentProblem + 1
  if self.currentProblem > #self.problems then
    self.currentProblem = 1
  end
end

function Enemy:takeDamage(amount)
  self.hp = math.max(0, self.hp - amount)
  return self.hp == 0
end

-- Battle system
Battle = {}
Battle.__index = Battle

function Battle.new(player, enemy)
  local self = setmetatable({}, Battle)
  self.player = player
  self.enemy = enemy
  self.state = "player_turn"
  self.turn = 0
  self.message = "Your turn! Choose an action."
  self.messageTimer = 0
  self.inputBuffer = ""
  self.currentProblem = enemy:getCurrentProblem()
  self.answerResult = nil
  self.answerTimer = 0
  self.enemyTurnDelay = 0
  return self
end

function Battle:askQuestion()
  self.currentProblem = self.enemy:getCurrentProblem()
  self.inputBuffer = ""
  self.state = "answering_question"
  self.message = "Answer the question:"
  self.messageTimer = 300
end

function Battle:playerAttack()
  if self.inputBuffer == "" then
    self.message = "Enter an answer!"
    self.messageTimer = 60
    return
  end
  
  local answer = self.inputBuffer:gsub("%s+", ""):lower()
  local correctAnswer = self.currentProblem.answer:gsub("%s+", ""):lower()
  
  if answer == correctAnswer then
    local damage = self.player.attack + math.random(1, 8)
    self.message = "CORRECT! +" .. damage .. " DMG"
    self.answerResult = true
    self.enemy:takeDamage(damage)
    self.messageTimer = 120
    
    if self.enemy.hp <= 0 then
      self:win()
      return
    else
      self.enemy:nextProblem()
      self.enemyTurnDelay = 120
      self.state = "enemy_turn"
    end
  else
    self.message = "WRONG! Answer was: " .. self.currentProblem.answer
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
  
  if not self.player:useMana(spell.cost) then
    self.message = "Not enough mana! Need " .. spell.cost
    self.messageTimer = 60
    return
  end
  
  local damage = spell.damage + math.random(1, 10)
  self.message = spell.name .. " +" .. damage .. " DMG"
  self.enemy:takeDamage(damage)
  self.messageTimer = 120
  
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
end

function Battle:enemyAttack()
  if self.enemyTurnDelay > 0 then
    self.enemyTurnDelay = self.enemyTurnDelay - 1
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
    self.player.defense = 5  -- Reset defense bonus
    self.state = "player_turn"
  end
end

function Battle:win()
  self.player.gold = self.player.gold + self.enemy.goldReward
  self.player:gainExp(self.enemy.expReward)
  self.state = "victory"
  self.message = "VICTORY! +" .. self.enemy.expReward .. " EXP, +" .. self.enemy.goldReward .. " GOLD"
  self.messageTimer = 180
end

function Battle:lose()
  self.player.gold = math.floor(self.player.gold / 2)
  self.state = "defeat"
  self.message = "DEFEAT! Lost half your gold"
  self.messageTimer = 180
end

-- Game Manager
game = {
  state = "menu",
  currentMenu = "main",
  player = nil,
  battle = nil,
  inputBuffer = "",
  selectedEnemy = 1,
  enemies = {
    {name = "Derivative Dragon", level = 1, color = {0.8, 0.2, 0.2}},
    {name = "Integral Imp", level = 2, color = {0.8, 0.5, 0.2}},
    {name = "Limit Leviathan", level = 3, color = {0.5, 0.2, 0.8}},
    {name = "Chain Rule Chimera", level = 4, color = {0.2, 0.5, 0.8}},
    {name = "Calculus Colossus", level = 5, color = {0.2, 0.8, 0.2}}
  }
}

function init()
  -- Initialize MicroStudio game
  screen:setClip(0, 0, 800, 480)
end

function update(dt)
  if game.battle then
    game.battle.messageTimer = math.max(0, game.battle.messageTimer - 1)
    game.battle.answerTimer = math.max(0, game.battle.answerTimer - 1)
    
    -- Auto-trigger enemy attacks
    if game.battle.state == "enemy_turn" then
      game.battle:enemyAttack()
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
  screen:clear(0.1, 0.1, 0.15)
  
  if game.currentMenu == "main" then
    drawMainMenu()
  elseif game.currentMenu == "new_game" then
    drawNewGameMenu()
  elseif game.currentMenu == "about" then
    drawAboutMenu()
  elseif game.currentMenu == "select_enemy" then
    drawSelectEnemyMenu()
  end
end

function drawMainMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 2)
  screen:print("CALCULUS RPG", 0.5, 0.9, 1)
  
  screen:setFont("arial", 1)
  screen:print("1. New Game", 0.5, 0.75, 1)
  screen:print("2. About", 0.5, 0.65, 1)
  screen:print("3. Quit", 0.5, 0.55, 1)
  
  screen:setColor(0.5, 0.5, 0.5)
  screen:setFont("arial", 0.8)
  screen:print("Use number keys to select", 0.5, 0.2, 1)
end

function drawNewGameMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.5)
  screen:print("Enter your name:", 0.5, 0.7, 1)
  
  screen:setFont("arial", 1.2)
  screen:print(game.inputBuffer .. "_", 0.5, 0.55, 1)
  
  screen:setColor(0.5, 0.5, 0.5)
  screen:setFont("arial", 0.8)
  screen:print("Press ENTER to start", 0.5, 0.3, 1)
end

function drawAboutMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.5)
  screen:print("ABOUT CALCULUS RPG", 0.5, 0.9, 1)
  
  screen:setColor(0.8, 0.8, 1)
  screen:setFont("arial", 0.7)
  screen:print("Battle enemies by solving calculus problems!", 0.5, 0.8, 1)
  screen:print("Gain experience, level up, and defeat the Calculus Colossus!", 0.5, 0.75, 1)
  screen:print("", 0.5, 0.70, 1)
  screen:print("Features:", 0.5, 0.65, 1)
  screen:print("- Answer derivative, integral, and limit questions", 0.5, 0.60, 1)
  screen:print("- Use spells to deal extra damage", 0.5, 0.55, 1)
  screen:print("- Rest and Study to improve stats", 0.5, 0.50, 1)
  screen:print("- 5 unique enemies with increasing difficulty", 0.5, 0.45, 1)
  
  screen:setColor(0.5, 0.5, 0.5)
  screen:print("Press ESC to return", 0.5, 0.2, 1)
end

function drawSelectEnemyMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.5)
  screen:print("SELECT ENEMY", 0.5, 0.9, 1)
  
  screen:setFont("arial", 1)
  for i, enemy in ipairs(game.enemies) do
    if i == game.selectedEnemy then
      screen:setColor(1, 1, 0.3)
    else
      screen:setColor(0.5, 0.5, 0.5)
    end
    screen:print(i .. ". " .. enemy.name .. " (Level " .. enemy.level .. ")", 0.5, 0.75 - (i-1) * 0.1, 1)
  end
  
  screen:setColor(0.5, 0.5, 0.5)
  screen:setFont("arial", 0.8)
  screen:print("Use UP/DOWN arrows to select, ENTER to battle, ESC to cancel", 0.5, 0.2, 1)
end

function drawGame()
  screen:clear(0.1, 0.15, 0.1)
  
  -- Draw player info
  screen:setColor(0.2, 0.8, 0.2)
  screen:setFont("arial", 1)
  screen:print(game.player.name, 0.05, 0.95, 0)
  
  screen:setColor(1, 0.3, 0.3)
  screen:print("HP: " .. game.player.hp .. "/" .. game.player.maxHP, 0.05, 0.90, 0)
  
  screen:setColor(0.3, 0.5, 1)
  screen:print("Mana: " .. game.player.mana .. "/" .. game.player.maxMana, 0.05, 0.85, 0)
  
  screen:setColor(1, 1, 0.3)
  screen:print("Level " .. game.player.level .. " | EXP: " .. game.player.exp .. "/" .. game.player.maxExp, 0.05, 0.80, 0)
  
  screen:setColor(1, 0.8, 0.2)
  screen:print("Gold: " .. game.player.gold, 0.05, 0.75, 0)
  
  -- Draw menu
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.2)
  screen:print("1. Battle", 0.5, 0.65, 1)
  screen:print("2. Status", 0.5, 0.55, 1)
  screen:print("3. Rest (10 Gold)", 0.5, 0.45, 1)
  screen:print("4. Study", 0.5, 0.35, 1)
  screen:print("5. Quit", 0.5, 0.25, 1)
end

function drawBattle()
  screen:clear(0.15, 0.1, 0.1)
  
  -- Draw player
  screen:setColor(0.2, 0.8, 0.2)
  screen:fillRect(0.15, 0.4, 0.1, 0.15)
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1)
  screen:print(game.player.name, 0.15, 0.35, 0.5)
  
  -- Draw enemy
  screen:setColor(game.battle.enemy.color[1], game.battle.enemy.color[2], game.battle.enemy.color[3])
  screen:fillRect(0.75, 0.4, 0.1, 0.15)
  screen:setColor(1, 1, 1)
  screen:print(game.battle.enemy.name, 0.75, 0.35, 0.5)
  
  -- Draw HP bars
  drawHPBar(0.2, 0.58, game.battle.player.hp, game.battle.player.maxHP, 0.2, 0.8, 0.2)
  drawHPBar(0.8, 0.58, game.battle.enemy.hp, game.battle.enemy.maxHP, 0.8, 0.2, 0.2)
  
  -- Draw battle UI panel
  screen:setColor(0.2, 0.2, 0.3)
  screen:fillRect(0, 0, 1, 0.3)
  
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 0.9)
  
  if game.battle.state == "answering_question" then
    drawQuestionUI()
  elseif game.battle.state == "player_turn" then
    drawPlayerTurnUI()
  elseif game.battle.state == "victory" then
    screen:setColor(0.2, 0.8, 0.2)
    screen:print(game.battle.message, 0.5, 0.15, 1)
    screen:setColor(0.5, 0.5, 0.5)
    screen:setFont("arial", 0.7)
    screen:print("Press ENTER to continue", 0.5, 0.05, 1)
  elseif game.battle.state == "defeat" then
    screen:setColor(0.8, 0.2, 0.2)
    screen:print(game.battle.message, 0.5, 0.15, 1)
    screen:setColor(0.5, 0.5, 0.5)
    screen:setFont("arial", 0.7)
    screen:print("Press ENTER to continue", 0.5, 0.05, 1)
  else
    screen:setColor(1, 1, 0.3)
    screen:print(game.battle.message, 0.5, 0.15, 1)
  end
end

function drawQuestionUI()
  screen:setFont("arial", 0.95)
  screen:setColor(1, 1, 1)
  screen:print("Q: " .. game.battle.currentProblem.question, 0.5, 0.20, 1)
  
  screen:setFont("arial", 0.8)
  screen:print("Answer: " .. game.battle.inputBuffer .. "_", 0.5, 0.12, 1)
  
  screen:setColor(0.5, 0.5, 0.5)
  screen:setFont("arial", 0.65)
  screen:print("ENTER=Submit | ESC=Cancel", 0.5, 0.05, 1)
end

function drawPlayerTurnUI()
  screen:setFont("arial", 0.8)
  screen:print("1.Answer | 2.Spell1 | 3.Spell2 | 4.Spell3 | 5.Defend", 0.5, 0.18, 1)
  
  if game.battle.messageTimer > 0 then
    if game.battle.answerResult == true then
      screen:setColor(0.2, 0.8, 0.2)
    elseif game.battle.answerResult == false then
      screen:setColor(0.8, 0.2, 0.2)
    else
      screen:setColor(1, 1, 0.3)
    end
    screen:print(game.battle.message, 0.5, 0.08, 1)
  end
end

function drawHPBar(x, y, hp, maxHP, r, g, b)
  local barWidth = 0.12
  local barHeight = 0.03
  
  screen:setColor(0.2, 0.2, 0.2)
  screen:fillRect(x - barWidth/2, y - barHeight/2, barWidth, barHeight)
  
  screen:setColor(r, g, b)
  screen:fillRect(x - barWidth/2, y - barHeight/2, barWidth * (hp / maxHP), barHeight)
  
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 0.6)
  screen:print(math.floor(hp) .. "/" .. math.floor(maxHP), x, y + 0.05, 1)
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
    if key == "1" then
      game.currentMenu = "new_game"
      game.inputBuffer = ""
    elseif key == "2" then
      game.currentMenu = "about"
    elseif key == "3" then
      -- Quit handled by MicroStudio
      game.state = "menu"
    end
  elseif game.currentMenu == "new_game" then
    if key == "return" then
      if game.inputBuffer ~= "" then
        game.player = Player.new(game.inputBuffer)
        game.state = "game"
        game.inputBuffer = ""
      end
    elseif key == "backspace" then
      game.inputBuffer = game.inputBuffer:sub(1, -2)
    elseif key == "escape" then
      game.currentMenu = "main"
    elseif #key == 1 and #game.inputBuffer < 20 then
      game.inputBuffer = game.inputBuffer .. key
    end
  elseif game.currentMenu == "about" then
    if key == "escape" then
      game.currentMenu = "main"
    end
  elseif game.currentMenu == "select_enemy" then
    if key == "up" then
      game.selectedEnemy = math.max(1, game.selectedEnemy - 1)
    elseif key == "down" then
      game.selectedEnemy = math.min(#game.enemies, game.selectedEnemy + 1)
    elseif key == "return" then
      local enemyData = game.enemies[game.selectedEnemy]
      local enemy = Enemy.new(enemyData.name, enemyData.level, enemyData.color)
      game.battle = Battle.new(game.player, enemy)
      game.state = "battle"
      game.currentMenu = "main"
    elseif key == "escape" then
      game.currentMenu = "main"
    end
  end
end

function handleGameKeyboard(key)
  if key == "1" then
    game.currentMenu = "select_enemy"
    game.state = "menu"
  elseif key == "2" then
    -- Status view - display in console for now
  elseif key == "3" then
    if game.player.gold >= 10 then
      game.player.hp = game.player.maxHP
      game.player.mana = game.player.maxMana
      game.player.gold = game.player.gold - 10
    end
  elseif key == "4" then
    -- Study - increases stats for gold
  elseif key == "5" then
    game.state = "menu"
    game.currentMenu = "main"
    game.player = nil
  end
end

function handleBattleKeyboard(key)
  if game.battle.state == "answering_question" then
    if key == "return" then
      game.battle:playerAttack()
    elseif key == "escape" then
      game.state = "game"
      game.battle = nil
    elseif key == "backspace" then
      game.battle.inputBuffer = game.battle.inputBuffer:sub(1, -2)
    elseif #key == 1 and #game.battle.inputBuffer < 30 then
      game.battle.inputBuffer = game.battle.inputBuffer .. key
    end
  elseif game.battle.state == "player_turn" then
    if key == "1" then
      game.battle:askQuestion()
    elseif key == "2" then
      game.battle:useSpell(1)
    elseif key == "3" then
      game.battle:useSpell(2)
    elseif key == "4" then
      game.battle:useSpell(3)
    elseif key == "5" then
      game.battle:defend()
    elseif key == "escape" then
      if math.random(1, 100) > 40 then
        game.battle.message = "Escaped!"
        game.battle.messageTimer = 120
        game.state = "game"
        game.battle = nil
      else
        game.battle.message = "Failed to escape!"
        game.battle.state = "enemy_turn"
      end
    end
  elseif game.battle.state == "victory" or game.battle.state == "defeat" then
    if key == "return" or key == "space" then
      game.state = "game"
      game.battle = nil
    end
  end
end
