import SpriteKit

class GameScene: SKScene {
    
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
    
    override func update(_ currentTime: TimeInterval) {
        // вызывается перед отрисовкой каждого кадра

    }
}
