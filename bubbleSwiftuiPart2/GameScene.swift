//
//  GameScene.swift
//  bubbleSwiftuiPart2
//
//  Created by Mario Fernandes on 22/04/2021.
//

import Foundation
import Combine
import SwiftUI
import SpriteKit
import swift_algorand_sdk

class GameScene: SKScene, ObservableObject {
    
    @Binding var horseAsset: Bool
    
    init(horseAsset: Binding<Bool>) {
        _horseAsset = horseAsset
        super.init(size: CGSize(width: 400, height: 800))
        self.scaleMode = .fill
        
      }
        
      required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
      }

    var theAssetState:bubbleGame = bubbleGame()

    var assetBubbleIsShowing = false
    
    let defaults:UserDefaults = UserDefaults.standard
    

    var timerLabel:SKLabelNode = SKLabelNode(fontNamed: "Arial")
    var bubbleLabel:SKLabelNode = SKLabelNode(fontNamed: "Arial")
    var totalBubbleLabel:SKLabelNode = SKLabelNode(fontNamed: "Arial")
    var ruleLabel:SKLabelNode = SKLabelNode(fontNamed: "Arial")

    var int = 0
    var nrOfBubbles = 5
    var number = 0
    var randomCount = Int.random(in: 1...3) + 1
    private var lastUpdateTime : TimeInterval = 0
  
    
    let background = SKSpriteNode(imageNamed: "bubbleBack")
    let timerCount = SKSpriteNode(imageNamed: "timerCount")
    let bubbleCount = SKSpriteNode(imageNamed: "bubbles")
    let totalBubbleCount = SKSpriteNode(imageNamed: "totalbubbles")
    let play: SKSpriteNode = SKSpriteNode(imageNamed: "play")
    let barrel: SKSpriteNode = SKSpriteNode(imageNamed: "barrel")
    let vase: SKSpriteNode = SKSpriteNode(imageNamed: "vase")
    let vase2: SKSpriteNode = SKSpriteNode(imageNamed: "vase2")
    let meat: SKSpriteNode = SKSpriteNode(imageNamed: "meat")
    let playerTang: SKSpriteNode = SKSpriteNode(imageNamed: "tang")
    var freezeMessage: SKSpriteNode = SKSpriteNode(imageNamed: "assetFreeze")
    let unFreezeMessage: SKSpriteNode = SKSpriteNode(imageNamed: "assetUnFreeze")
    let trashMessage: SKSpriteNode = SKSpriteNode(imageNamed: "trash")
    
    // -------music//
    
    let musicNode = SKAudioNode(fileNamed: "PoolParty.wav")
    private let playPopSound = SKAction.playSoundFileNamed("pop.mp3",
    waitForCompletion: false)
    private let playErrorSound = SKAction.playSoundFileNamed("Error.wav",
    waitForCompletion: false)
    private let playTrashSound = SKAction.playSoundFileNamed("trash.wav",
    waitForCompletion: false)
    
    var arrplayer :[SKSpriteNode] = [SKSpriteNode]()
    var playerNameArr = [String]()
    var theTimer = Timer()
    var secondsLeft = 15
    var startTime = 0
    var bubblesCatch = 0
    var totalBubblesCatch = 0
    
//    tang fish
    let mainTangNumber:SKLabelNode = SKLabelNode(fontNamed: "Arial")
    var tangNumber = 3
    var tangIsShowing = false
    
    var freezeAsaState = true
    var onAsaState = true
//    --------unfreeze------
    var unfreezeNumber = 0
    
    //    purestake ------- //
        
    var ALGOD_API_ADDR="https://testnet-algorand.api.purestake.io/ps2"
    var ALGOD_API_TOKEN="Gs---------------------------5"
    var ALGOD_API_PORT=""

        
        @State var teste:String = "Hello"
        @State var resultadoLda:Float = 0
        @State var assetTotal:Int64 = 10000
        @State var assetDecimals:Int64 = 0
        @State var  assetUnitName = "HR"
        @State var  assetName = "Hero"
        @State var  url = "https://www.3dlifestudio.com"
        @State var defaultFrozen = false
    
  
    
    override func didMove(to view: SKView) {
        
        musicNode.autoplayLooped = true
        musicNode.isPositional = false
        // Add the audio the scene
        addChild(musicNode)


        self.lastUpdateTime = 0
        
        if defaults.object(forKey: "increaseTime") != nil {
            
            startTime = defaults.integer(forKey: "increaseTime")
            print(startTime)
            
        }else  {
            
            startTime = secondsLeft
            print(startTime)
        }
        
        setupStartButton()
        
        background.position = CGPoint(x: 0, y: 0)
        background.name = "background"
        addChild(background)
       
        timerCount.position = CGPoint(x: -130, y: 80)
        timerCount.zPosition = 90
        timerCount.name = "timerCount"
        addChild(timerCount)
        
        timerLabel.text = "\(startTime)"
        timerLabel.fontSize = 24
       
        timerLabel.fontColor = SKColor.white
        timerLabel.horizontalAlignmentMode = .left
        timerLabel.position = CGPoint(x: -115, y: 80)
        timerLabel.zPosition = 100
        addChild(timerLabel)
        
        bubbleCount.position = CGPoint(x: 0, y: 80)
        bubbleCount.zPosition = 90
        bubbleCount.name = "timerCount"
        addChild(bubbleCount)
        
        bubbleLabel.text = "\(bubblesCatch)"
        bubbleLabel.fontSize = 24
       
        bubbleLabel.fontColor = SKColor.white
        bubbleLabel.horizontalAlignmentMode = .left
        bubbleLabel.position = CGPoint(x: 15, y: 80)
        bubbleLabel.zPosition = 100
        addChild(bubbleLabel)
      
        totalBubbleCount.position = CGPoint(x: 125, y: 80)
        totalBubbleCount.zPosition = 99
        totalBubbleCount.name = "timerCount"
        addChild(totalBubbleCount)
        
        totalBubbleLabel.text = "\(totalBubblesCatch)"
        totalBubbleLabel.fontSize = 24
       
        totalBubbleLabel.fontColor = SKColor.white
        totalBubbleLabel.horizontalAlignmentMode = .left
        totalBubbleLabel.position = CGPoint(x: 140, y: 80)
        totalBubbleLabel.zPosition = 100
        addChild(totalBubbleLabel)
        
       
    }
    
  
    
    func UnfreezeASA(){
        
        if  unfreezeNumber == 4 && onAsaState == false  {
            
            freezeAsaState = false
            onAsaState = true
            freezeASA()
            unfreezeNumber = 0
            
        }
       
        
    }
    
    func freezeASA(){
        
        let algodClient=AlgodClient(host: ALGOD_API_ADDR, port: ALGOD_API_PORT, token: ALGOD_API_TOKEN)
        algodClient.set(key: "X-API-KeY")
        
        do {
            
            let mnemonic1 = "digital special special special special special special special special special special special special special special special special special special special special special special special special"
            
            let account1 = try Account(mnemonic1)
           
            let senderAddress1 = account1.getAddress()
            
            let mnemonic3 = "diet special special special special special special special special special special special special special special special special special special special special special special special special"
            
            let account3 = try Account(mnemonic3)

            let senderAddress3 = account3.getAddress()
            
            algodClient.transactionParams().execute(){paramResponse in
                if(!(paramResponse.isSuccessful)){
                    print(paramResponse.errorDescription!);
                    print("passou")
                    return;
                }
               
                let tx = Transaction.assetFreezeTransactionBuilder()
                    
                    .setSender(senderAddress1)
                    .freezeTarget(freezeTarget:senderAddress3)
                    .freezeState(freezeState: self.freezeAsaState)
                    .assetIndex(assetIndex: Int64((self.defaults.integer(forKey: "AssetId"))))
                    .suggestedParams(params:paramResponse.data!).build();

//                print(Int64((self.defaults.integer(forKey: "AssetId"))))
                
                let signedTrans=account1.signTransaction(tx: tx)
                //
                let encodedTx:[Int8]=CustomEncoder.encodeToMsgPack(signedTrans)
                algodClient.rawTransaction().rawtxn(rawtaxn: encodedTx).execute(){
                    response in
                    if(response.isSuccessful){
                        print("freeze ok!")
                        
                        if  self.freezeAsaState == true {
                            
                            self.showFreezeMessage()
                            
                        } else if  self.freezeAsaState == false {
                            
                            self.showUnFreezeMessage()
                            self.freezeAsaState = true
                        }
                        
                        
                    }else{
                        print("freeze Fail!")
                        //
                    }
                    
                }
                
            }//paramresponse
            
        } catch {
            //handle error
            print(error)
        }
        print("algo buy!")
        
    }

    
    func addTimeBonus() {
        
        secondsLeft = secondsLeft + 5
        defaults.set( secondsLeft, forKey: "increaseTime")
        self.startTime = self.defaults.integer(forKey: "increaseTime")
        self.timerLabel.text = "\(self.startTime)"
     
    }
    
    func unlockAsset() {
       
        theAssetState.add(assetStateChange: false)
        self.horseAsset = false
    }
  
    func setupStartButton() {
        
        ruleLabel.text = "Touch the Seahorse balls in descending order."
        ruleLabel.fontSize = 18
        ruleLabel.fontColor = SKColor.white
        ruleLabel.horizontalAlignmentMode = .left
        ruleLabel.position = CGPoint(x: -180 , y: frame.midY - 200)
        ruleLabel.zPosition = 100
        addChild(ruleLabel)
     
        play.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        play.zPosition = 2
        
        self.addChild(play)
        play.name = "playBtn"
        
      
        // Add animation
        let scaleUp = SKAction.scale(to: 0.55, duration: 0.65)
        let scaleDown = SKAction.scale(to: 0.50, duration: 0.65)
        let playBounce = SKAction.sequence([scaleDown, scaleUp])
        let bounceRepeat = SKAction.repeatForever(playBounce)
        play.run(bounceRepeat)
        

    }
    
    func showFreezeMessage() {
        
        
        freezeMessage.position = CGPoint(x: frame.midX, y: frame.midY - 800)
        
        freezeMessage.zPosition = 8
        
        self.addChild(freezeMessage)
        freezeMessage.name = "freezeMessage"
        
        
        let actionFreezeMoveUp = SKAction.move(to: CGPoint(x: frame.midX, y: frame.midY - 100), duration: 0.7)
        // 2
        let actionWait = SKAction.wait(forDuration: 2.6)
        
        let actionFreezeMovedown = SKAction.move(to: CGPoint(x: frame.midX, y: frame.midY - 800), duration: 0.7)
        // 3
        let actionRemoveFreezeMovedown = SKAction.removeFromParent()
        // 4
        let sequence = SKAction.sequence([actionFreezeMoveUp, actionWait, actionFreezeMovedown, actionRemoveFreezeMovedown])
        // 5
        freezeMessage.run(sequence)
        
        
        
        trashMessage.position = CGPoint(x: frame.midX, y: frame.midY - 800)
        
        trashMessage.zPosition = 8
        
        self.addChild(trashMessage)
        trashMessage.name = "trashMessage"
        
        
        let actiontrashMoveUp = SKAction.move(to: CGPoint(x: frame.midX, y: frame.midY - 200), duration: 1.0)
        // 2
        let actiontrashWait = SKAction.wait(forDuration: 2.0)
        
        let actiontrashMovedown = SKAction.move(to: CGPoint(x: frame.midX, y: frame.midY - 800), duration: 1.0)
        // 3
        let actionRemovetrash = SKAction.removeFromParent()
        // 4
        let sequenceTrash = SKAction.sequence([actiontrashMoveUp, actiontrashWait, actiontrashMovedown, actionRemovetrash])
        // 5
        trashMessage.run(sequenceTrash)
        
       
    }
    
    
    func showUnFreezeMessage() {
        
        
        unFreezeMessage.position = CGPoint(x: frame.midX, y: frame.midY - 800)
        
        unFreezeMessage.zPosition = 8
        
        self.addChild(unFreezeMessage)
        unFreezeMessage.name = "unFreezeMessage"
        
        
        let actionUnFreezeMoveUp = SKAction.move(to: CGPoint(x: frame.midX, y: frame.midY - 100), duration: 0.7)
        // 2
        let actionWaitUnFreeze = SKAction.wait(forDuration: 2.0)
        
        let actionUnFreezeMovedown = SKAction.move(to: CGPoint(x: frame.midX, y: frame.midY - 800), duration: 0.7)
        // 3
        let actionRemoveUnFreezeMovedown = SKAction.removeFromParent()
        // 4
        let sequenceUnFreeze = SKAction.sequence([actionUnFreezeMoveUp, actionWaitUnFreeze, actionUnFreezeMovedown, actionRemoveUnFreezeMovedown])
        // 5
        unFreezeMessage.run(sequenceUnFreeze)
        
       
    }
    
    
    func showStartButton() {
        play.run(SKAction.fadeIn(withDuration: 0.25))
        ruleLabel.run(SKAction.fadeIn(withDuration: 0.25))
    }
    func hideStartButton() {
        play.run(SKAction.fadeOut(withDuration: 0.25))
        ruleLabel.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    
    func gameOver(){
        
        if defaults.object(forKey: "increaseTime") != nil {
            
            startTime = defaults.integer(forKey: "increaseTime")
            self.timerLabel.text = "\(self.startTime)"
            print(startTime)
            
        }else  {
            
            startTime = secondsLeft
//            print(startTime)
        }
        
        showStartButton()
        nrOfBubbles = 5
        number = 0
        bubblesCatch = 0
        bubbleLabel.text = "\(bubblesCatch)"
        timerLabel.text =  "\(startTime)"
        playerNameArr.removeAll()
        for enemy in arrplayer {
            enemy.removeFromParent()
            
        }
        
        tangIsShowing = false
        self.cleanElements()
        
    }
    
    
    func cleanElements() {
        
        barrel.removeFromParent()
        vase.removeFromParent()
        vase2.removeFromParent()
        meat.removeFromParent()
        playerTang.removeFromParent()
        mainTangNumber.removeFromParent()
    }
    
    
    func startTheTimer() {
        
        theTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdownTimer), userInfo: nil, repeats: true)
    }
    
    @objc func countdownTimer(){
        
        
        startTime -= 1
        
        timerLabel.text =  "\(startTime)"
        
        
        if startTime == 0 {
            theTimer.invalidate()
            gameOver()
        }
        //
    }
    
    func createPlayer(){
        
        
        for int in 1...nrOfBubbles where int < nrOfBubbles {
            
            
            populateStage()
            number += randomCount
            
            
        }
        
    }
    
    
    func createTrash() {

        barrel.position = CGPoint(x: -150, y: -350)
        barrel.zPosition = 4
        barrel.name = "barrel"
        self.addChild(barrel)

        vase.position = CGPoint(x: -50, y: -350)
        vase.zPosition = 4
        vase.name = "vase"
        self.addChild(vase)

        vase2.position = CGPoint(x: 50, y: -350)
        vase2.zPosition = 4
        vase2.name = "vase2"
        self.addChild(vase2)

        meat.position = CGPoint(x: 150, y: -350)
        meat.zPosition = 4
        meat.name = "meat"
        self.addChild(meat)
  
    }
    
    
    func createTangFish() {
        
        let randomNumber = Int.random(in: 1...20) + 1
        let randomX = CGFloat.random(in: -100...100)
        let randomY = CGFloat.random(in: -300...5)
        
        mainTangNumber.fontSize = 28
        mainTangNumber.verticalAlignmentMode = .center
        mainTangNumber.fontColor = SKColor.black
        mainTangNumber.text = String(randomNumber)
        mainTangNumber.zPosition = 3

        playerTang.position = CGPoint(x: randomX, y: randomY)
        playerTang.zPosition = 4
        playerTang.name = "tang"

        playerTang.addChild(mainTangNumber)
        
        self.addChild(playerTang)
         
        
    }
    
    func playPop() {
    let removeFromParent = SKAction.removeFromParent()
    let actionPopGroup = SKAction.group([playPopSound, removeFromParent])
    self.run(actionPopGroup)
    }
    
    func playError() {
    let removeFromParent = SKAction.removeFromParent()
    let actionErrorGroup = SKAction.group([playErrorSound, removeFromParent])
    self.run(actionErrorGroup)
    }
    
    func playTrash() {
    let removeFromParent = SKAction.removeFromParent()
    let actionTrashGroup = SKAction.group([playTrashSound, removeFromParent])
    self.run(actionTrashGroup)
    }
    
    
    
    
    func populateStage() {

        let randomX = CGFloat.random(in: -160...160)
        let randomY = CGFloat.random(in: -370...5)
        let bubbleNumberText:SKLabelNode = SKLabelNode(fontNamed: "Arial")

        bubbleNumberText.fontSize = 40
        bubbleNumberText.verticalAlignmentMode = .center
        bubbleNumberText.fontColor = SKColor.black
        bubbleNumberText.text = String(number)
        bubbleNumberText.zPosition = 3

       let player: SKSpriteNode = SKSpriteNode(imageNamed: "horse")
        player.position = CGPoint(x: randomX, y: randomY)
        player.zPosition = 4
        player.name = String(number)
        player.addChild(bubbleNumberText)
        self.addChild(player)

        playerNameArr.append(player.name!)
        arrplayer.append(player)
//
    }
         
    override func update(_ currentTime: TimeInterval) {

    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
        
        let touchNBonus = atPoint (pos)
        
        if touchNBonus.name == "bonusTime"{
            
            
        }
        
        let touchN = atPoint (pos)
        
        if touchN.name == "playBtn"{
            
            createPlayer()
            
            startTheTimer()
            hideStartButton()

        }
        
         
        let touchTang = atPoint (pos)
        
        if touchTang.name == "tang"{
            
           
            touchTang.removeFromParent()
            self.playError()
            createTrash()
            if onAsaState == true {
                onAsaState = false
                freezeASA()
            }

        }
        
//   -----Barrel touch -----------//
        let touchBarrel = atPoint (pos)
        
        if touchBarrel.name == "barrel"{

            touchBarrel.removeFromParent()
            self.playTrash()
            unfreezeNumber = unfreezeNumber + 1
            UnfreezeASA()

        }
        
        //   -----Vase touch -----------//
        let touchvase = atPoint (pos)
        
        if touchvase.name == "vase"{
            
            touchvase.removeFromParent()
            self.playTrash()
            unfreezeNumber = unfreezeNumber + 1
            UnfreezeASA()

        }
        
        //   -----Vase2 touch -----------//
        let touchvase2 = atPoint (pos)
        
        if touchvase2.name == "vase2"{
            
            touchvase2.removeFromParent()
            self.playTrash()
            unfreezeNumber = unfreezeNumber + 1
            UnfreezeASA()

        }
        
        //   -----Vase2 touch -----------//
        let touchmeat = atPoint (pos)
        
        if touchmeat.name == "meat"{
            
            touchmeat.removeFromParent()
            self.playTrash()
            unfreezeNumber = unfreezeNumber + 1
            UnfreezeASA()

        }
        
  
        
        let touchedN = nodes(at: pos)
        for touchedNode in touchedN {
           
            
            if touchedNode.name == playerNameArr.last {
                
                touchedNode.removeFromParent()
                playerNameArr.removeLast()
     
                bubblesCatch = bubblesCatch + 1
                
                bubbleLabel.text = "\(bubblesCatch)"
                
                totalBubblesCatch = bubblesCatch
                
                totalBubbleLabel.text = "\(totalBubblesCatch)"
                
                self.playPop()
                
                if totalBubblesCatch >= 15 {
                    
                    unlockAsset()
                    
                   
                }
      
                if playerNameArr.isEmpty {
                   
                    self.cleanElements()
                    createPlayer()
                    nrOfBubbles = nrOfBubbles+1
                    number = 0
                    tangIsShowing = false
                    if tangIsShowing == false {
                        createTangFish()
                        tangIsShowing = true
                    }
                    
                }
                
                return
                
                
            }else if touchedNode.name != playerNameArr.last && touchedNode.name != "background" && touchedNode.name != "playBtn" && touchedNode.name != "tang" && touchedNode.name != nil && touchedNode.name != "barrel" && touchedNode.name != "vase" && touchedNode.name != "vase2" && touchedNode.name != "meat" {
//                print("fail")
                print(touchedNode.name as Any)
                theTimer.invalidate()
                gameOver()
                //
                
                
            }
            
        }
        
        
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

//
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
}



