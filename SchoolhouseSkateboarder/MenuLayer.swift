import SpriteKit

class MenuLayer: SKSpriteNode {
    
    // отображает сообщение и иногда текущий счет
    func display(message: String, score: Int?) {
        
        // создаем надпись сообщения, используя передаваемое сообщение
        let messageLabel: SKLabelNode = SKLabelNode(text: message)
        
        // устанавливаем начальное положение надписи в левой стороне слоя меню
        let messageX = -frame.width
        let messageY = frame.height / 2.0
        messageLabel.position = CGPoint(x: messageX, y: messageY)
        
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.fontName = "Courier-Bold"
        messageLabel.fontSize = 48.0
        messageLabel.zPosition = 20
        addChild(messageLabel)
        
        // анимируем движение надписи сообщения к центру экрана
        let finalX = frame.width / 2.0
        let messageAction = SKAction.moveTo(x: finalX, duration: 0.3)
        messageLabel.run(messageAction)
        
        // если количество очков было передано методу, показываем надпись на экране
        if let scoreToDisplay = score {
            // создаем текст с количеством очков из числа score
            let scoreString = String(format: "Очки:%d", scoreToDisplay)
            let scoreLabel: SKLabelNode = SKLabelNode(text: scoreString)
            // задаем начальное положение надписи справа от слоя меню
            let scoreLabelX = frame.width
            let scoreLabelY = messageLabel.position.y - messageLabel.frame.height
            scoreLabel.position = CGPoint(x: scoreLabelX, y: scoreLabelY)
            
            scoreLabel.horizontalAlignmentMode = .center
            scoreLabel.fontName = "Courier-Bold"
            scoreLabel.fontSize = 32.0
            scoreLabel.zPosition = 20
            addChild(scoreLabel)
            // анимируем движение надписи в центр экрана
            let scoreAction = SKAction.moveTo(x: finalX, duration: 0.3)
            scoreLabel.run(scoreAction)
        }
    }

}
