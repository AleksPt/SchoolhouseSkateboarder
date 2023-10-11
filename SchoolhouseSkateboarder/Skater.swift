import SpriteKit

class Skater: SKSpriteNode {
    var velocity = CGPointZero
    var minimumY: CGFloat = 0.0
    var jumpSpeed: CGFloat = 20.0
    var isOnGround = true
    
    func setupPhysicBody() {
        
        if let skaterTexture = texture {
            physicsBody = SKPhysicsBody(texture: skaterTexture, size: size)
            physicsBody?.isDynamic = true
            physicsBody?.density = 6.0
            physicsBody?.allowsRotation = true
            physicsBody?.angularDamping = 4.0
            
            physicsBody?.categoryBitMask = PhysicsCategory.skater
            physicsBody?.collisionBitMask = PhysicsCategory.brick
            physicsBody?.contactTestBitMask = PhysicsCategory.brick | PhysicsCategory.gem
        }
    }
    
    func createSparks() {
        
        // находим файл эмиттера искр в проекте
        let bundle = Bundle.main
        if let sparksPath = bundle.path(forResource: "sparks", ofType: "sks") {
            
            // создаем узел эмиттера искр
            let sparksNode = NSKeyedUnarchiver.unarchiveObject(withFile: sparksPath) as! SKEmitterNode
            sparksNode.position = CGPoint(x: 0.0, y: -50.0)
            addChild(sparksNode)
            
            // производим действие, ждем полсекунды, а затем удаляем эмиттер
            let wathAction = SKAction.wait(forDuration: 0.5)
            let removeAction = SKAction.removeFromParent()
            let waitThenRemove = SKAction.sequence([wathAction, removeAction])
            sparksNode.run(wathAction)
        }
    }
}
