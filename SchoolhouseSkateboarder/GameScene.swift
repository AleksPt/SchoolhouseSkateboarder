import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        
        anchorPoint = CGPoint.zero
        
        // добавляем фоновое изображение
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        }
        
    override func update(_ currentTime: TimeInterval) {

    }
}
