import SpriteKit

// эта структура содержит различные физические категории, и мы можем определить, какие типы объектов сталкиваются или контактируют друг с другом
struct PhysicsCategory {
    static let skater: UInt32 = 0x1 << 0
    static let brick: UInt32 = 0x1 << 1
    static let gem: UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // enum для положения секции по оси y
    // секции на земле низкие, а секции на верхней платформе высокие
    enum BrickLevel: CGFloat {
        case low = 0.0
        case high = 100.0
    }
    
    // этот enum определяет состояния, в которых может находиться игра
    enum GameState {
        case notRunning
        case running
    }
    
    // массив, содержащий все текущие секции тротуара
    var bricks = [SKSpriteNode]()
    
    // массив, содержащий все активные алмазы
    var gems = [SKSpriteNode]()
    
    // размер секций на тротуаре
    var brickSize = CGSize.zero
    
    // текущий уровень определяет положение по оси y для новых секций
    var brickLevel = BrickLevel.low
    
    // отслеживаем текущее состояние игры
    var gameState = GameState.notRunning
    
    // настройка скорости движения направо для игры
    var scrollSpeed: CGFloat = 5.0
    let startingScrollSpeed: CGFloat = 5.0
    
    // константа для гравитации (как быстро объекты падают на землю)
    let gravitySpeed: CGFloat = 1.5
    
    // свойства для отслеживания результата
    var score: Int = 0
    var highScore: Int = 0
    var lastScoreUpdateTime: TimeInterval = 0.0
    
    // время последнего вызова для метода обновления
    var lastUpdateTime: TimeInterval?
    
    // создаем героя игры - скейтбордистку
    let skater = Skater(imageNamed: "skater")
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        physicsWorld.contactDelegate = self
        
        anchorPoint = CGPoint.zero
        
        // добавляем фоновое изображение
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        
        setupLabels()
        
        // настраиваем свойства скейтбордистки и добавляем ее в сцену
        skater.setupPhysicBody()
        addChild(skater)
        
        // добавляем распознаватель нажатия, чтобы знать, когда пользователь нажимает на экран
        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
        
        // добавляем слой меню с текстом "Нажмите, чтобы играть"
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
        menuLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        menuLayer.position = CGPoint(x: 0.0, y: 0.0)
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display(message: "Нажмите, чтобы играть", score: nil)
        addChild(menuLayer)
        
    }
    
    func resetSkater() {
        // задаем начальное положение скейтбордистки, zPosition и minimumY
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64.0
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.minimumY = skaterY
        
        skater.zRotation = 0.0
        skater.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        skater.physicsBody?.angularVelocity = 0.0
        
    }
    
    func setupLabels() {
        
        // надпись со словами "очки" в верхнем левом углу
        let scoreTextLabel: SKLabelNode = SKLabelNode(text: "очки")
        scoreTextLabel.position = CGPoint(x: 100.0, y: frame.size.height - 30.0)
        scoreTextLabel.horizontalAlignmentMode = .left
        scoreTextLabel.fontName = "Courier-Bold"
        scoreTextLabel.fontSize = 30.0
        scoreTextLabel.zPosition = 20
        addChild(scoreTextLabel)
        
        // надпись с количеством очков игрока в текущей игре
        let scoreLabel: SKLabelNode = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: 100.0, y: frame.size.height - 70.0)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontName = "Courier-Bold"
        scoreLabel.fontSize = 50.0
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        // надпись "лучший результат" в правом верхнем углу
        let highScoreTextLabel: SKLabelNode = SKLabelNode(text: "лучший результат")
        highScoreTextLabel.position = CGPoint(x: frame.size.width - 100.0, y: frame.size.height - 30.0)
        highScoreTextLabel.horizontalAlignmentMode = .right
        highScoreTextLabel.fontName = "Courier-Bold"
        highScoreTextLabel.fontSize = 30.0
        highScoreTextLabel.zPosition = 20.0
        addChild(highScoreTextLabel)
        
        // надпись с максимумом набранных игроком очков
        let highScoreLabel: SKLabelNode = SKLabelNode(text: "0")
        highScoreLabel.position = CGPoint(x: frame.size.width - 100.0, y: frame.size.height - 70.0)
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.fontName = "Courier-Bold"
        highScoreLabel.fontSize = 50.0
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.zPosition = 20.0
        addChild(highScoreLabel)
    }
    
    func updateScoreLabelText() {
        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = String(format: "%d", score)
        }
    }
    
    func updateHighScoreLabelText() {
        if let highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode {
            highScoreLabel.text = String(format: "%d", highScore)
        }
    }
    
    func spawnBrick(atPosition position: CGPoint) -> SKSpriteNode {
        
        // создаем спрайт секции и добавляем его к сцене
        let brick = SKSpriteNode(imageNamed: "sidewalk")
        brick.position = position
        brick.zPosition = 8
        addChild(brick)
        
        // обновляем свойство brickSize реальным значением размера секции
        brickSize = brick.size
        
        // добавляем новую секцию к массиву
        bricks.append(brick)
        
        // настройка физического тела секции
        let center = brick.centerRect.origin
        brick.physicsBody = SKPhysicsBody(rectangleOf: brickSize, center: center)
        brick.physicsBody?.affectedByGravity = false
        brick.physicsBody?.categoryBitMask = PhysicsCategory.brick
        brick.physicsBody?.collisionBitMask = 0
        
        // возвращаем новую секцию вызывающему коду
        return brick
    }
    
    func spawnGem(atPosition position: CGPoint) {
        
        // создаем спрайт для алмаза и добавляем его к сцене
        let gem = SKSpriteNode(imageNamed: "gem")
        gem.position = position
        gem.zPosition = 9
        addChild(gem)
        gem.physicsBody = SKPhysicsBody(rectangleOf: gem.size, center: gem.centerRect.origin)
        gem.physicsBody?.categoryBitMask = PhysicsCategory.gem
        gem.physicsBody?.affectedByGravity = false
        
        // добавляем новый алмаз к массиву
        gems.append(gem)
    }
    
    func removeGem(_ gem: SKSpriteNode) {
        
        gem.removeFromParent()
        
        if let gemIndex = gems.firstIndex(of: gem) {
            gems.remove(at: gemIndex)
        }
    }
    
    func updateBricks(withScrollAmount currentScrollAmount: CGFloat) {
        
        // отслеживаем самое большое значение по оси x для всех существующих секций
        var farthestRightBrickX: CGFloat = 0
        
        for brick in bricks {
            let newX = brick.position.x - currentScrollAmount
            
            // если секция сместилась слишком далеко влево (за пределы экрана), удалите ее
            if newX < -brickSize.width {
                brick.removeFromParent()
                if let brickIndex = bricks.firstIndex(of: brick) {
                    bricks.remove(at: brickIndex)
                }
            } else {
                
                // для секции, оставшейся на экране, обновляем положение
                brick.position = CGPoint(x: newX, y: brick.position.y)
                
                // обновляем значение для крайней правой секции
                if brick.position.x > farthestRightBrickX {
                    farthestRightBrickX = brick.position.x
                }
            }
        }
        
        // цикл while, обеспечивающий постоянное наполнение экрана секциями
        while farthestRightBrickX < frame.width {
            var brickX = farthestRightBrickX + brickSize.width + 1.0
            let brickY = (brickSize.height / 2.0) + brickLevel.rawValue
            // время от времени мы оставляем разрывы, через которые герой должен перепрыгнуть
            let randomNumber = arc4random_uniform(99)
            
            if randomNumber < 5 && score > 5 {
                
                // шанс на то, что у нас возникнет разрыв между секциями после того, как игрок набрал 10 очков
                let gap = 20.0 * scrollSpeed
                brickX += gap
                
                // на каждом разрыве добавляем алмаз
                let randomGemYAmount = CGFloat(arc4random_uniform(150))
                let newGemY = brickY + skater.size.height + randomGemYAmount
                let newGemX = brickX - gap / 2.0
                
                spawnGem(atPosition: CGPoint(x: newGemX, y: newGemY))
            }
            else if randomNumber < 10 && score > 10 {
                // шанс на изменение уровня секции Y после того, как игрок набрал 20 очков
                if brickLevel == .high {
                    brickLevel = .low
                } else if brickLevel == .low {
                    brickLevel = .high
                }
            }
            
            // добавляем новую секцию и обновляем положение самой правой
            let newBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY))
            farthestRightBrickX = newBrick.position.x
        }
    }
    
    func updateGem(withScrollAmount currentScrollAmount: CGFloat) {
        
        for gem in gems {
            
            // обновляем положение каждого алмаза
            let thisGemX = gem.position.x - currentScrollAmount
            gem.position = CGPoint(x: thisGemX, y: gem.position.y)
            
            // удаляем любые алмазы, ушедшие с экрана
            if gem.position.x < 0.0 {
                removeGem(gem)
            }
        }
    }
    
    func updateSkater() {
        
        // определяем, находится ли скейтбордистка на земле
        if let velocityY = skater.physicsBody?.velocity.dy {
            if velocityY < -100.0 || velocityY > 100.0 {
                skater.isOnGround = false
            }
        }
        
        // проверяем, должна ли игра закончится
        let isOffScreen = skater.position.y < 0.0 || skater.position.x < 0.0
        
        let maxRotation = CGFloat(GLKMathDegreesToRadians(85.0))
        let isTippedOver = skater.zRotation > maxRotation || skater.zRotation < -maxRotation
        
        if isOffScreen || isTippedOver {
            gameOver()
        }
    }
    
    func updateScore(withCurrentTime currentTime: TimeInterval) {
        
        // количество очков игрока увеличивается по мере игры
        // счет обновляется каждую секунду
        
        let elapsedTime = currentTime - lastScoreUpdateTime
        
        if elapsedTime > 0.5 {
            
            // увеличиваем количество очков
            score += Int(scrollSpeed)
            
            // присваиваем свойству lastScoreUpdateTime значение текущего времени
            lastScoreUpdateTime = currentTime
            
            updateScoreLabelText()
        }
    }
    
    func startGame() {
        
        // перезагрузка начальных условий при запуске новой игры
        gameState = .running
        resetSkater()
        
        score = 0
        
        scrollSpeed = startingScrollSpeed
        brickLevel = .low
        lastUpdateTime = nil
        
        for brick in bricks {
            brick.removeFromParent()
        }
        bricks.removeAll(keepingCapacity: true)
        
        for gem in gems {
            removeGem(gem)
        }
    }
    
    func gameOver() {
        
        // по завершении игры проверяем, добился ли игрок нового рекорда
        
        gameState = .notRunning
        
        if score > highScore {
            highScore = score
            updateHighScoreLabelText()
        }
        
        // показываем надпись "Игра окончена"
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
        menuLayer.anchorPoint = CGPoint.zero
        menuLayer.position = CGPoint.zero
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display(message: "Игра окончена!", score: score)
        addChild(menuLayer)
        
    }
    
    // вызывается перед отрисовкой каждого кадра
    override func update(_ currentTime: TimeInterval) {
        if gameState != .running {
            return
        }
        
        // медленно увеличиваем значение scrollSpeed по мере развития игры
        scrollSpeed += 0.01
        
        // определяем время, прошедшее с момента последнего вызова update
        var elapsedTime: TimeInterval = 0.0
        if let lastTimeStamp = lastUpdateTime {
            elapsedTime = currentTime - lastTimeStamp
        }
        
        lastUpdateTime = currentTime
        
        let expectedElapsedTime: TimeInterval = 1.0 / 60.0
        
        // рассчитываем, насколько далеко должны сдвинуться объекты при данном обновлении
        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime)
        let currentScrollAmount = scrollSpeed * scrollAdjustment
        
        updateBricks(withScrollAmount: currentScrollAmount)
        
        updateSkater()
        
        updateGem(withScrollAmount: currentScrollAmount)
        
        updateScore(withCurrentTime: currentTime)
        
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        
        if gameState == .running {
            // скейтбордистка прыгает, если игрок нажимает на экран, пока она находится на земле
            if skater.isOnGround {
                skater.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 260.0))
            }
        } else {
            // если игра не запущена, нажатие на экран запускает новую игру
            if let menuLayer: SKSpriteNode = childNode(withName: "menuLayer") as? SKSpriteNode {
                menuLayer.removeFromParent()
            }
            startGame()
        }
    }
    
    // MARK: - SKPhysicsContactDelegate Methods
    func didBegin(_ contact: SKPhysicsContact) {
        // проверяем, есть ли контакт между скейтбордисткой и секцией
        if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.brick {
            skater.isOnGround = true
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.gem {
            
            // скейтбордистка коснулась алмаза, поэтому мы его убираем
            if let gem = contact.bodyB.node as? SKSpriteNode {
                removeGem(gem)
                // даем игроку 50 очков за собранный алмаз
                score += 50
                updateScoreLabelText()
            }
        }
    }
    
}

