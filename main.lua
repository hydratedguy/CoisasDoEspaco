-- FALTA IMPLEMENTAR:
-- COLISÃO ENTRE ALIEN E NAVE DO PLAYER(DERROTA)


love.graphics.setDefaultFilter("nearest", "nearest")

local gameOver = false
local gameWin = false

local speed1 = true
local speed2 = false

local menu = true
local spawnEnemies = false
local playing = false

local score = 0
-------------------------------PLAYER----------------------------------
local player = {}

player.x = love.graphics.getWidth()/7
player.y = 160
player.width = 11
player.height = 11
player.speed = 70
player.life = 3
player.bullets = {}
player.cooldown = 20
player.image = love.graphics.newImage("Player/spaceship.png")

function player.fire()
  if player.cooldown <= 0 then
    player.cooldown = 20
    bullet = {}
    bullet.x = player.x + 4.5
    bullet.y = player.y - 3
    table.insert(player.bullets, bullet)
  end
end

-------------------------------ENEMY------------------------------------

local enemies = {}
local enemyBullets = {}

local right = true
local left = false

function spawnEnemy(x, y, alien)
  enemy = {}
  enemy.x = x
  enemy.y = y
  enemy.height = 11
  enemy.width = 11
  enemy.life = 2
  enemy.type = alien
  enemy.img = love.graphics.newImage("Aliens/alien" .. alien ..".png")
  enemy.damaged = love.graphics.newImage("Aliens/alien" .. alien .."damaged.png")
  table.insert(enemies, enemy)
end


function enemyFire()

  math.randomseed(os.time())
    
  local n = math.random(1, #enemies)
    
  bullet = {}
    
  for i, e in pairs(enemies) do
    if i == n then
      bullet.x = e.x + 1
      bullet.y = e.y + e.height
      bullet.w = 3
      bullet.h = 11
    end
  end
    
  table.insert(enemyBullets, bullet)
end


------------------------------------------------------------------------
function PBulletEnemyColl(enemies, bullets)
  for i ,e in ipairs(enemies) do
    for k, b in pairs(bullets) do
      if b.y <= e.y + e.height and b.x > e.x and b.x < e.x + e.width then
        if e.life > 1 then
          e.life = e.life - 1
          e.img = e.damaged
        elseif e.life == 1 then
          table.remove(enemies, i)
          invaderKilled:play()
          score = score + 10 * e.y/(t1 - tup)
        end
        table.remove(bullets, k)
      end
    end
  end
end

function EBulletsPlayerColl(bullets)
  for k, b in pairs(bullets) do
    if b.y >= player.y and b.y <= player.y + player.height and b.x + b.w >= player.x and b.x <= player.x + player.width then
      if player.life > 1 then
        playerDamage:play()
        player.life = player.life - 1
      elseif player.life == 1 then
        playing = false
        gameOver = true
        gameMusic:stop()
        defeatSound:play()
      end
      table.remove(bullets, k)
    end
  end
end


function love.keypressed(key)
  if playing == false and menu == true then
    if key == "return" then
      music:stop()
      startSound:play()
      gameMusic:play()
      menu = false
      spawnEnemies = true
      playing = true
      t0 = os.time()
    end
  end
end

function love.load()
  
  love.window.setMode(1200, 900)
  
  love.window.setTitle("Coisas do Espaço")
  
  font = love.graphics.newFont("font.ttf", 8)
  love.graphics.setFont(font)
  
  icon = love.image.newImageData("Aliens/alien1.png")
  love.window.setIcon(icon)
  
  music = love.audio.newSource("Sounds/menumusic.mp3", "stream")
  music:setLooping(true)
  music:play()
  
  startSound = love.audio.newSource("Sounds/startGame.mp3", "static")
  
  playerShoot = love.audio.newSource("Sounds/shoot.wav", "static")
  playerDamage = love.audio.newSource("Sounds/playerDamage.wav", "static")
  playerHeart = love.graphics.newImage("Player/life.png")
  
  invaderKilled = love.audio.newSource("Sounds/invaderkilled.wav", "static")
  
  gameMusic = love.audio.newSource("Sounds/gameMusic.mp3", "stream")

  victorySound = love.audio.newSource("Sounds/victory.mp3", "static")
  defeatSound = love.audio.newSource("Sounds/defeat.ogg", "static")
  
  enemyBullet1 = love.graphics.newImage("Aliens/alienbullet1.png")
  
  t1 = os.time()
  
  background_image = love.graphics.newImage("background.png")
  
  gameName = love.graphics.newImage("gamename.png")


end

function love.update(dt)
  
  tup = os.time()
  
  if spawnEnemies == true then
    for i = 0, 11 do
      spawnEnemy(i * 20, 0, 3)
    end
    
    for i = 0, 11 do
      spawnEnemy(i * 20, 15, 2)
    end
    
    for i = 0, 11 do
      spawnEnemy(i * 20, 35, 1)
    end
    
    spawnEnemies = false
  end
  
  
  if playing == true then
    
    if #enemies == 0 then
      gameWin = true
      gameMusic:stop()
      victorySound:play()
      playing = false
    end
    
    if tup - t0 >= 1 then
      enemyFire()
      t0 = tup
    end
    
    player.cooldown = player.cooldown - 1
    
    PBulletEnemyColl(enemies, player.bullets)
    EBulletsPlayerColl(enemyBullets)
    
    if love.keyboard.isDown("right") then
      player.x = player.x + (player.speed * dt)
    elseif love.keyboard.isDown("left") then
      player.x = player.x - (player.speed * dt)
    end
    
    if player.x <= 0 then
      player.x = 0
    elseif player.x + player.width >= 240 then
      player.x = 240 - player.width
    end
    
    if love.keyboard.isDown("space") then
      player.fire()
      playerShoot:play()
    end
    
    for _, e in pairs(enemies) do
      
      if e.y >= 175 then
        playing = false
        gameOver = true
        gameMusic:stop()
        defeatSound:play()
      end
      
      if (e.x + e.width) >= 240 then
        right = false
        left = true
      elseif e.x <= 0 then
        right = true
        left = false
      end

      if right == true then
        if speed2 == true then
          e.x = e.x + 20 * dt
        end
        e.x = e.x + 10 * dt
      elseif left == true then
        if speed2 == true then
          e.x = e.x - 20 * dt
        end
        e.x = e.x - 10 * dt
      end
      
      if e.y >= 70 then
        speed1 = false
        speed2 = true
      end
      
      if speed1 == true then
        e.y = e.y + 2 * dt
      elseif speed2 == true then
        e.y = e.y + 6 * dt
      end
    end
    
    for i,b in ipairs(player.bullets) do
      if b.y < -10 then
        table.remove(player.bullets, i)
      end
      b.y = b.y - 2
    end
    
    for i,b in ipairs(enemyBullets) do
      if b.y > 200 then
        table.remove(enemyBullets, i)
      end
      b.y = b.y + 2
    end

  end
end

function love.draw()
  
  love.graphics.draw(background_image)

  love.graphics.scale(5)
  
  if menu == true then
    love.graphics.draw(gameName, 55, 15)
    if (tup - t1) % 2 == 1 then
      love.graphics.print("APERTE ENTER PARA JOGAR !", 55, 145)
    end
  end
  
  if playing == true then
    
    love.graphics.print(string.format("SCORE: %.0f", score))
    

    if player.life == 3 then
      love.graphics.draw(playerHeart, 5, 172)
      love.graphics.draw(playerHeart, 11, 172)
      love.graphics.draw(playerHeart, 17, 172)
    elseif player.life == 2 then
      love.graphics.draw(playerHeart, 5, 172)
      love.graphics.draw(playerHeart, 11, 172)
    elseif player.life == 1 then
      love.graphics.draw(playerHeart, 5, 172)
    end
    
    love.graphics.setColor(0, 0, 1.0)
    love.graphics.setColor(1.0, 1.0, 1.0)
    
    for _, b in pairs(enemyBullets) do
      love.graphics.draw(enemyBullet1, b.x, b.y)
    end
    
    love.graphics.draw(player.image, player.x, player.y)
    
    for _,e in pairs(enemies) do    
        love.graphics.draw(e.img, e.x, e.y)
    end
    
    for _, b in pairs(player.bullets) do
      love.graphics.rectangle("fill", b.x, b.y, 2, 2)
    end
    
  end
  
  if gameOver == true then
    love.graphics.print("OS ALIENÍGENAS", 85, 70)
    love.graphics.print("DESTRUIRAM O PLANETA !", 65, 90)
  end
  
  if gameWin == true then
    love.graphics.print(string.format("SCORE: %.0f", score))
    love.graphics.print("VOCÊ SALVOU", 85, 70)
    love.graphics.print("O PLANETA, DOS ALIENÍGENAS !", 45, 90)
  end
  
end