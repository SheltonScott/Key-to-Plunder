//
//  GameScene.swift
//  Key to Plunder
//
//  Created by scott shelton on 11/19/18.
//  Copyright © 2018 scott shelton. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player = SKSpriteNode(imageNamed: "adventurer-idle-0-right")
    var playerFacing = "right"
    
    var playerIdle0RightFrames = [SKTexture]()
    var playerIdle0LeftFrames = [SKTexture]()
    
    var playerRunRightFrames = [SKTexture]()
    var playerRunLeftFrames = [SKTexture]()
    
    var playerJumpRightFrames = [SKTexture]()
    var playerJumpLeftFrames = [SKTexture]()
    
    let cam = SKCameraNode()
    
    let rightArrow = SKSpriteNode(imageNamed: "right-arrow")
    let leftArrow = SKSpriteNode(imageNamed: "left-arrow")
    let jumpArrow = SKSpriteNode(imageNamed: "jump-arrow")
    
    let treasureChest = SKSpriteNode(imageNamed: "Treasure Chest 0")
    var chestFrames = [SKTexture]()
    
    enum CategoryMask: UInt32 {
        case player = 0b01 // 1
        case treasureChest = 0b10 // 2
    }
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        physicsWorld.contactDelegate = self
        
        for node in self.children {
            if (node.name == "Game Tile Map Node") {
                if let someTileMap:SKTileMapNode = node as? SKTileMapNode {
                    print(someTileMap.mapSize.width)
                    giveTileMapPhysicsBody(map: someTileMap)
                    someTileMap.removeFromParent()
                }
            }
        }
        
        player.position = CGPoint(x: frame.minX + 32, y: frame.midY)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.restitution = 0
        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
        player.name = "player"
        
        self.addChild(player)
        
        self.camera = cam
        self.addChild(cam)
        
        let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: player)
        cam.constraints = [constraint]
        
        rightArrow.position = CGPoint(x: cam.position.x - 400, y: cam.position.y - 300)
        rightArrow.zPosition = 1.0
        cam.addChild(rightArrow)
        
        leftArrow.position = CGPoint(x: cam.position.x - 600, y: cam.position.y - 300)
        leftArrow.zPosition = 1.0
        cam.addChild(leftArrow)
        
        jumpArrow.position = CGPoint(x: cam.position.x + 600, y: cam.position.y - 300)
        jumpArrow.zPosition = 1.0
        cam.addChild(jumpArrow)
        
        treasureChest.position = CGPoint(x: 5591, y: frame.maxY - 224)
        treasureChest.physicsBody = SKPhysicsBody(texture: treasureChest.texture!, size: treasureChest.size)
        treasureChest.physicsBody!.allowsRotation = false
        treasureChest.physicsBody!.restitution = 0
        treasureChest.physicsBody!.isDynamic = false
        treasureChest.name = "treasureChest"
        self.addChild(treasureChest)
        
        let textureAtlasIdle0Right = SKTextureAtlas(named: "IdleRight")
        for index in 0..<textureAtlasIdle0Right.textureNames.count {
            let textureName = "adventurer-idle-\(index)-right"
            playerIdle0RightFrames.append(textureAtlasIdle0Right.textureNamed(textureName))
        }
        let textureAtlasIdle0Left = SKTextureAtlas(named: "IdleLeft")
        for index in 0..<textureAtlasIdle0Left.textureNames.count {
            let textureName = "adventurer-idle-\(index)-left"
            playerIdle0LeftFrames.append(textureAtlasIdle0Left.textureNamed(textureName))
        }
        
        let textureAtlasRunRight = SKTextureAtlas(named: "RunRight")
        for index in 0..<textureAtlasRunRight.textureNames.count {
            let textureName = "adventurer-run-\(index)-right"
            playerRunRightFrames.append(textureAtlasRunRight.textureNamed(textureName))
        }
        let textureAtlasRunLeft = SKTextureAtlas(named: "RunLeft")
        for index in 0..<textureAtlasRunLeft.textureNames.count {
            let textureName = "adventurer-run-\(index)-left"
            playerRunLeftFrames.append(textureAtlasRunLeft.textureNamed(textureName))
        }
        
        let textureAtlasJumpRight = SKTextureAtlas(named: "JumpRight")
        for index in 0..<textureAtlasJumpRight.textureNames.count {
            let textureName = "adventurer-jump-\(index)-right"
            playerJumpRightFrames.append(textureAtlasJumpRight.textureNamed(textureName))
        }
        let textureAtlasJumpLeft = SKTextureAtlas(named: "JumpLeft")
        for index in 0..<textureAtlasJumpLeft.textureNames.count {
            let textureName = "adventurer-jump-\(index)-left"
            playerJumpLeftFrames.append(textureAtlasJumpLeft.textureNamed(textureName))
        }
        
        let textureAtlasChest = SKTextureAtlas(named: "Chest")
        for index in 0..<textureAtlasChest.textureNames.count {
            let textureName = "Treasure Chest \(index)"
            chestFrames.append(textureAtlasChest.textureNamed(textureName))
        }
        
        player.run(SKAction.repeatForever(SKAction.animate(with: playerIdle0RightFrames, timePerFrame: 0.5)))
    }
    
    func giveTileMapPhysicsBody(map: SKTileMapNode) {
        let tileMap = map
        let startingLocation:CGPoint = tileMap.position
        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row) {
                    let tileArray = tileDefinition.textures
                    
                    let tileTexture = tileArray[0]
                    
                    let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width / 2)
                    let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height / 2)
                    
                    let tileNode = SKSpriteNode(texture:tileTexture)
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.physicsBody = SKPhysicsBody(texture: tileTexture, size: CGSize(width: (tileTexture.size().width), height: (tileTexture.size().height)))
                    tileNode.physicsBody?.linearDamping = 60.0
                    tileNode.physicsBody?.affectedByGravity = false
                    tileNode.physicsBody?.allowsRotation = false
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.physicsBody?.friction = 1
                    self.addChild(tileNode)
                    
                    tileNode.position = CGPoint(x: tileNode.position.x + startingLocation.x, y: tileNode.position.y + startingLocation.y)
                }
            }
        }
    }
    
    func collision(_ player: SKSpriteNode,_ monster: SKSpriteNode) {
        if (monster.name == "treasureChest") {
            treasureChest.run(SKAction.animate(with: chestFrames, timePerFrame: 0.5))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node!.name == "player" {
            collision(contact.bodyA.node as! SKSpriteNode, contact.bodyB.node! as! SKSpriteNode)
        } else if contact.bodyB.node?.name == "player" {
            collision(contact.bodyB.node! as! SKSpriteNode, contact.bodyA.node! as! SKSpriteNode)
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if leftArrow.contains(touch.location(in: cam)) {
            player.run(SKAction.repeatForever(SKAction.group([SKAction.moveBy(x: -160, y: 0, duration: 0.5), SKAction.animate(with: playerRunLeftFrames, timePerFrame: 0.08)])))
            playerFacing = "left"
        }
        if rightArrow.contains(touch.location(in: cam)) {
            player.run(SKAction.repeatForever(SKAction.group([SKAction.moveBy(x: 160, y: 0, duration: 0.5), SKAction.animate(with: playerRunRightFrames, timePerFrame: 0.08)])))
            playerFacing = "right"
        }
        if jumpArrow.contains(touch.location(in: cam)) {
            if playerFacing == "left" {
                player.run(SKAction.group([SKAction.moveBy(x: 0, y: 224, duration: 0.5), SKAction.animate(with: playerJumpLeftFrames, timePerFrame: 0.08)]))
            }
        }
        if jumpArrow.contains(touch.location(in: cam)) {
            if playerFacing == "right" {
                player.run(SKAction.group([SKAction.moveBy(x: 0, y: 224, duration: 0.5), SKAction.animate(with: playerJumpRightFrames, timePerFrame: 0.08)]))
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if leftArrow.contains(touch.location(in: cam)) {
            player.removeAllActions()
            player.run(SKAction.repeatForever(SKAction.animate(with: playerIdle0LeftFrames, timePerFrame: 0.5)))
        }
        if rightArrow.contains(touch.location(in: cam)) {
            player.removeAllActions()
            player.run(SKAction.repeatForever(SKAction.animate(with: playerIdle0RightFrames, timePerFrame: 0.5)))
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
    }
}
