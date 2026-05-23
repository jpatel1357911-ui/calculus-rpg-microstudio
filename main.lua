-- Calculus RPG for MicroStudio - ENHANCED VERSION
-- A math-themed RPG adventure with improved gameplay mechanics

-- Game states
GAME_STATE = "menu"
CURRENT_MENU = "main"

-- Difficulty settings
DIFFICULTY = {
  EASY = {multiplier = 0.7, timeLimit = 15},
  NORMAL = {multiplier = 1.0, timeLimit = 10},
  HARD = {multiplier = 1.5, timeLimit = 7}
}

-- Player class
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
  self.streak = 0  -- Correct answer streak
  self.maxStreak = 0
  self.x = 200
  self.y = 240
  
  self.spells = {
    {name = "Derivative Bolt", cost = 15, damage = 20, description = "d/dx attack!"},
    {name = "Integral Shield", cost = 20, defense = 10, description = "∫ protection"},
    {name = "Limit Break", cost = 25, damage = 35, description = "→ limit!"}
  }
  
  self.achievements = {
    firstVictory = false,
    streak5 = false,
    level5 = false,
    defeatBoss = false
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

function Player:gainExp(amount, multiplier)
  multiplier = multiplier or 1.0
  local totalExp = math.floor(amount * multiplier)
  self.exp = self.exp + totalExp
  
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
  
  if self.level == 5 then
    self.achievements.level5 = true
  end
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

function Player:resetStreak()
  self.streak = 0
end

function Player:addStreak()
  self.streak = self.streak + 1
  if self.streak > self.maxStreak then
    self.maxStreak = self.streak
  end
  if self.streak >= 5 then
    self.achievements.streak5 = true
  end
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
  self.difficultyMultiplier = 1.0
  return self
end

function Enemy:generateProblems()
  -- Expanded problem set with difficulty levels
  local problems = {
    -- Easy
    {question = "d/dx(x²)", answer = "2x", explanation = "Power rule: 2x", difficulty = 1},
    {question = "d/dx(3x)", answer = "3", explanation = "Constant multiple", difficulty = 1},
    {question = "∫3 dx", answer = "3x", explanation = "Constant integral", difficulty = 1},
    
    -- Medium
    {question = "d/dx(x³)", answer = "3x2", explanation = "d/dx(x³) = 3x²", difficulty = 2},
    {question = "d/dx(sin x)", answer = "cos(x)", explanation = "Trig derivative", difficulty = 2},
    {question = "d/dx(e^x)", answer = "ex", explanation = "Exponential", difficulty = 2},
    {question = "∫2x dx", answer = "x2", explanation = "∫2x dx = x² + C", difficulty = 2},
    {question = "∫cos(x) dx", answer = "sin(x)", explanation = "Trig integral", difficulty = 2},
    
    -- Hard
    {question = "d/dx(ln x)", answer = "1/x", explanation = "Logarithmic derivative", difficulty = 3},
    {question = "lim(x→0) sin(x)/x", answer = "1", explanation = "Fundamental limit", difficulty = 3},
    {question = "d/dx(x⁴-3x²)", answer = "4x3-6x", explanation = "Polynomial derivatives", difficulty = 3},
    {question = "d/dx(x·sin x)", answer = "sin(x)+x·cos(x)", explanation = "Product rule", difficulty = 3},
    {question = "∫sin(x) dx", answer = "-cos(x)", explanation = "Trig integral", difficulty = 3},
  }
  return problems
end

function Enemy:getRandomProblem()
  -- Filter problems by difficulty
  local filtered = {}
  for _, p in ipairs(self.problems) do
    if p.difficulty <= math.ceil(self.level) then
      table.insert(filtered, p)
    end
  end
  if #filtered == 0 then filtered = self.problems end
  return filtered[math.random(1, #filtered)]
end

function Enemy:getCurrentProblem()
  return self.problems[self.currentProblem]
end

function Enemy:takeDamage(amount)
  self.hp = math.max(0, self.hp - amount)
  return self.hp == 0
end

-- Battle system with enhanced mechanics
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
  self.answerTimer = 0
  self.enemyTurnDelay = 0
  self.turnCount = 0
  self.totalDamage = 0
  self.battleLog = {}
  self.comboMultiplier = 1.0
  return self
end

function Battle:askQuestion()
  self.currentProblem = self.enemy:getRandomProblem()
  self.inputBuffer = ""
  self.state = "answering_question"
  self.message = "Answer the question (Time: 10s)"
  self.messageTimer = 600  -- 10 seconds in frames
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
    -- Correct answer!
    self.player:addStreak()
    self.comboMultiplier = 1.0 + (self.player.streak * 0.1)
    
    local baseDamage = self.player.attack + math.random(1, 8)
    local damage = math.floor(baseDamage * self.comboMultiplier)
    
    self.message = "✓ CORRECT! ×" .. string.format("%.1f", self.comboMultiplier) .. " +" .. damage .. " DMG"
    self.answerResult = true
    self.enemy:takeDamage(damage)
    self.totalDamage = self.totalDamage + damage
    self.messageTimer = 120
    
    if self.enemy.hp <= 0 then
      self:win()
      return
    else
      self.enemyTurnDelay = 120
      self.state = "enemy_turn"
    end
  else
    -- Wrong answer
    self.player:resetStreak()
    self.comboMultiplier = 1.0
    self.message = "✗ WRONG! Ans: " .. self.currentProblem.answer
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
  
  local baseDamage = spell.damage
  local damage = math.floor(baseDamage + math.random(1, 10))
  self.message = spell.name .. " +" .. damage .. " DMG"
  self.enemy:takeDamage(damage)
  self.totalDamage = self.totalDamage + damage
  self.messageTimer = 120
  self.player:resetStreak()
  
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
  self.player.achievements.firstVictory = true
  
  -- Bonus multiplier based on remaining HP
  local hpBonus = math.floor((self.player.hp / self.player.maxHP) * 0.5)
  local totalExp = self.enemy.expReward + hpBonus
  
  self.player.gold = self.player.gold + self.enemy.goldReward
  self.player:gainExp(totalExp, self.player.difficulty.multiplier)
  
  self.state = "victory"
  self.message = "VICTORY! +" .. totalExp .. " EXP, +" .. self.enemy.goldReward .. " GOLD"
  self.messageTimer = 180
end

function Battle:lose()
  self.player.gold = math.floor(self.player.gold / 2)
  self.state = "defeat"
  self.message = "DEFEAT! Lost half your gold. Better luck next time!"
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
  selectedDifficulty = 2,  -- NORMAL
  gameStats = {
    totalBattles = 0,
    totalWins = 0,
    totalLosses = 0,
    highestLevel = 0
  },
  enemies = {
    {name = "Derivative Dragon", level = 1, color = {0.8, 0.2, 0.2}},
    {name = "Integral Imp", level = 2, color = {0.8, 0.5, 0.2}},
    {name = "Limit Leviathan", level = 3, color = {0.5, 0.2, 0.8}},
    {name = "Chain Rule Chimera", level = 4, color = {0.2, 0.5, 0.8}},
    {name = "Calculus Colossus", level = 5, color = {0.2, 0.8, 0.2}}
  },
  difficulties = {
    {name = "EASY", modifier = 0.7},
    {name = "NORMAL", modifier = 1.0},
    {name = "HARD", modifier = 1.5}
  }
}

function init()
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
    
    -- Time limit for answering
    if game.battle.state == "answering_question" and game.battle.messageTimer <= 0 then
      game.battle.message = "TIME'S UP!"
      game.battle.messageTimer = 60
      game.battle.answerResult = false
      game.battle.player:resetStreak()
      game.battle.enemyTurnDelay = 180
      game.battle.state = "enemy_turn"
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
  elseif game.currentMenu == "about" then
    drawAboutMenu()
  elseif game.currentMenu == "stats" then
    drawStatsMenu()
  end
end

function drawMainMenu()
  screen:setColor(0.2, 1, 0.8)
  screen:setFont("arial", 2.5)
  screen:print("CALCULUS RPG", 0.5, 0.9, 1)
  
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.2)
  screen:print("1. New Game", 0.5, 0.75, 1)
  screen:print("2. Statistics", 0.5, 0.65, 1)
  screen:print("3. About", 0.5, 0.55, 1)
  screen:print("4. Quit", 0.5, 0.45, 1)
  
  screen:setColor(0.5, 1, 0.8)
  screen:setFont("arial", 0.9)
  screen:print("Master calculus through epic battles!", 0.5, 0.3, 1)
end

function drawDifficultyMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.8)
  screen:print("SELECT DIFFICULTY", 0.5, 0.9, 1)
  
  screen:setFont("arial", 1.2)
  for i, diff in ipairs(game.difficulties) do
    if i == game.selectedDifficulty then
      screen:setColor(1, 1, 0.3)
      screen:print("> " .. diff.name .. " <", 0.5, 0.75 - (i-1) * 0.15, 1)
    else
      screen:setColor(0.6, 0.6, 0.6)
      screen:print(diff.name, 0.5, 0.75 - (i-1) * 0.15, 1)
    end
  end
  
  screen:setColor(0.5, 0.5, 0.5)
  screen:setFont("arial", 0.8)
  screen:print("UP/DOWN to select, ENTER to confirm", 0.5, 0.2, 1)
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
  
  screen:setColor(0.5, 0.5, 0.5)
  screen:setFont("arial", 0.8)
  screen:print("UP/DOWN select, ENTER battle, ESC back", 0.5, 0.2, 1)
end

function drawAboutMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.5)
  screen:print("ABOUT CALCULUS RPG", 0.5, 0.9, 1)
  
  screen:setColor(0.8, 0.8, 1)
  screen:setFont("arial", 0.8)
  screen:print("Answer calculus questions to defeat enemies!", 0.5, 0.8, 1)
  screen:print("Features: Combo multipliers, achievements, difficulty modes", 0.5, 0.75, 1)
  screen:print("", 0.5, 0.70, 1)
  screen:print("Press ESC to return", 0.5, 0.2, 1)
end

function drawStatsMenu()
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.5)
  screen:print("STATISTICS", 0.5, 0.9, 1)
  
  screen:setColor(0.8, 1, 0.8)
  screen:setFont("arial", 0.9)
  screen:print("Total Battles: " .. game.gameStats.totalBattles, 0.5, 0.8, 1)
  screen:print("Wins: " .. game.gameStats.totalWins .. " | Losses: " .. game.gameStats.totalLosses, 0.5, 0.75, 1)
  screen:print("Highest Level: " .. game.gameStats.highestLevel, 0.5, 0.70, 1)
  
  screen:setColor(0.5, 0.5, 0.5)
  screen:setFont("arial", 0.8)
  screen:print("Press ESC to return", 0.5, 0.2, 1)
end

function drawGame()
  screen:clear(0.08, 0.08, 0.12)
  
  -- Draw player stats with better layout
  screen:setColor(0.2, 1, 0.8)
  screen:setFont("arial", 1.1)
  screen:print(game.player.name .. " - Level " .. game.player.level, 0.05, 0.95, 0)
  
  screen:setColor(1, 0.3, 0.3)
  screen:print("HP: " .. game.player.hp .. "/" .. game.player.maxHP, 0.05, 0.90, 0)
  
  screen:setColor(0.3, 0.7, 1)
  screen:print("Mana: " .. game.player.mana .. "/" .. game.player.maxMana, 0.05, 0.85, 0)
  
  screen:setColor(1, 1, 0.3)
  screen:print("EXP: " .. game.player.exp .. "/" .. game.player.maxExp, 0.05, 0.80, 0)
  
  screen:setColor(1, 0.8, 0.2)
  screen:print("Gold: " .. game.player.gold, 0.05, 0.75, 0)
  
  screen:setColor(0.8, 1, 0.8)
  screen:print("Best Streak: " .. game.player.maxStreak, 0.05, 0.70, 0)
  
  -- Draw menu options
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 1.3)
  screen:print("1. BATTLE", 0.5, 0.65, 1)
  screen:print("2. REST (10 Gold)", 0.5, 0.55, 1)
  screen:print("3. ACHIEVEMENTS", 0.5, 0.45, 1)
  screen:print("4. QUIT", 0.5, 0.35, 1)
end

function drawBattle()
  screen:clear(0.12, 0.08, 0.15)
  
  -- Draw combatants
  screen:setColor(0.2, 0.9, 0.2)
  screen:fillRect(0.1, 0.35, 0.12, 0.2)
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 0.9)
  screen:print(game.player.name, 0.1, 0.3, 0.5)
  
  screen:setColor(game.battle.enemy.color[1], game.battle.enemy.color[2], game.battle.enemy.color[3])
  screen:fillRect(0.78, 0.35, 0.12, 0.2)
  screen:setColor(1, 1, 1)
  screen:print(game.battle.enemy.name, 0.78, 0.3, 0.5)
  
  -- Draw HP bars with values
  drawHPBar(0.16, 0.62, game.battle.player.hp, game.battle.player.maxHP, 0.2, 0.9, 0.2)
  drawHPBar(0.84, 0.62, game.battle.enemy.hp, game.battle.enemy.maxHP, 0.8, 0.2, 0.2)
  
  -- Draw battle UI
  screen:setColor(0.15, 0.15, 0.2)
  screen:fillRect(0, 0, 1, 0.25)
  
  screen:setColor(1, 1, 1)
  screen:setFont("arial", 0.85)
  
  if game.battle.state == "answering_question" then
    drawQuestionUI()
  elseif game.battle.state == "player_turn" then
    drawPlayerTurnUI()
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

function drawQuestionUI()
  screen:setFont("arial", 0.95)
  screen:setColor(1, 1, 1)
  screen:print("Q: " .. game.battle.currentProblem.question, 0.5, 0.18, 1)
  
  screen:setFont("arial", 0.85)
  screen:print("Answer: " .. game.battle.inputBuffer .. "_", 0.5, 0.10, 1)
  
  -- Show time remaining
  local timeRemaining = math.ceil(game.battle.messageTimer / 60)
  if timeRemaining > 0 then
    screen:setColor(1, 1, 0.3)
    screen:print("Time: " .. timeRemaining .. "s", 0.5, 0.03, 1)
  end
end

function drawPlayerTurnUI()
  screen:setFont("arial", 0.75)
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
    if key == "1" then
      game.currentMenu = "new_game"
      game.inputBuffer = ""
    elseif key == "2" then
      game.currentMenu = "stats"
    elseif key == "3" then
      game.currentMenu = "about"
    elseif key == "4" then
      os.exit()
    end
  elseif game.currentMenu == "new_game" then
    if key == "return" then
      if game.inputBuffer ~= "" then
        game.currentMenu = "difficulty"
      end
    elseif key == "backspace" then
      game.inputBuffer = game.inputBuffer:sub(1, -2)
    elseif key == "escape" then
      game.currentMenu = "main"
    elseif #key == 1 and #game.inputBuffer < 20 then
      game.inputBuffer = game.inputBuffer .. key
    end
  elseif game.currentMenu == "difficulty" then
    if key == "up" then
      game.selectedDifficulty = math.max(1, game.selectedDifficulty - 1)
    elseif key == "down" then
      game.selectedDifficulty = math.min(#game.difficulties, game.selectedDifficulty + 1)
    elseif key == "return" then
      local difficulty = DIFFICULTY.NORMAL
      if game.selectedDifficulty == 1 then difficulty = DIFFICULTY.EASY
      elseif game.selectedDifficulty == 3 then difficulty = DIFFICULTY.HARD end
      
      game.player = Player.new(game.inputBuffer, difficulty)
      game.currentMenu = "select_enemy"
      game.selectedEnemy = 1
    elseif key == "escape" then
      game.currentMenu = "new_game"
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
      game.battle:askQuestion()
      game.state = "battle"
    elseif key == "escape" then
      game.currentMenu = "main"
      game.player = nil
    end
  elseif game.currentMenu == "about" then
    if key == "escape" then
      game.currentMenu = "main"
    end
  elseif game.currentMenu == "stats" then
    if key == "escape" then
      game.currentMenu = "main"
    end
  end
end

function handleGameKeyboard(key)
  if key == "1" then
    game.currentMenu = "select_enemy"
    game.state = "menu"
    game.selectedEnemy = 1
  elseif key == "2" then
    if game.player.gold >= 10 then
      game.player.hp = game.player.maxHP
      game.player.mana = game.player.maxMana
      game.player.gold = game.player.gold - 10
      game.player:resetStreak()
    end
  elseif key == "3" then
    -- Show achievements (simplified)
  elseif key == "4" then
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
      game.gameStats.totalBattles = game.gameStats.totalBattles + 1
      if game.battle.state == "victory" then
        game.gameStats.totalWins = game.gameStats.totalWins + 1
      else
        game.gameStats.totalLosses = game.gameStats.totalLosses + 1
      end
      if game.player.level > game.gameStats.highestLevel then
        game.gameStats.highestLevel = game.player.level
      end
      
      game.state = "game"
      game.battle = nil
    end
  end
end
