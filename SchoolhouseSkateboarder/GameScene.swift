import SpriteKit

class GameScene: SKScene {
    
    // массив, содержащий все текущие секции тротуара
    var bricks = [SKSpriteNode]()
    
    // размер секций на тротуаре
    var brickSize = CGSize.zero
    
    // настройка скорости движения направо для игры
    var scrollSpeed: CGFloat = 5.0
    
    // время последнего вызова для метода обновления
    var lastUpdateTime: TimeInterval?
    
    // создаем героя игры - скейтбордистку
    let skater = Skater(imageNamed: "skater")
    
    override func didMove(to view: SKView) {
        
        anchorPoint = CGPoint.zero
        
        // добавляем фоновое изображение
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        
        // настраиваем свойства скейтбордистки и добавляем ее в сцену 
        resetSkater()
        addChild(skater)
        }
        
    func resetSkater() {
        // задаем начальное положение скейтбордистки, zPosition и minimumY
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64.0
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.minimumY = skaterY
        
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
        
        // возвращаем новую секцию вызывающему коду
        return brick
    }
    
    func updateBricks(withScrollAmount currentScrollAmount: CGFloat) {
        
        // отслеживаем самое большое значение по оси x для всех существующих секций
        var farthestRightBrickX: CGFloat = 0.0
        
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
            let brickY = brickSize.height / 2.0
            // время от времени мы оставляем разрывы, через которые герой должен перепрыгнуть
            let randomNumber = arc4random_uniform(99)
            
            if randomNumber < 5 {
                
                // 5-процентный шанс на то, что у нас возникнет разрыв между секциями
                let gap = 20.0 * scrollSpeed
                brickX += gap
            }
            
            // добавляем новую секцию и обновляем положение самой правой
            let newBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY))
            farthestRightBrickX = newBrick.position.x
        }
    }
    
    // вызывается перед отрисовкой каждого кадра
    override func update(_ currentTime: TimeInterval) {
        
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

    }
}
