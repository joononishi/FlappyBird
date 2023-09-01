import SpriteKit
import AVFoundation//BGM用の設定
class GameScene: SKScene, SKPhysicsContactDelegate {
    var audioPlayer: AVAudioPlayer!//BGM用の設定
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    let itemCategory: UInt32 = 1 << 4       //課題に応じて追加
    
    var score = 0
    var itemScore = 0
    var scoreLabelNode:SKLabelNode!
    var itemScoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard
    var spawnLoop: SKAction!

    
    
    override func didMove(to view: SKView) {
    physicsWorld.gravity = CGVector(dx: 0, dy: -4)    // ←追加
    physicsWorld.contactDelegate = self // ←追加
    backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
    scrollNode = SKNode()
    addChild(scrollNode)
    // 壁用のノード
    wallNode = SKNode()
    scrollNode.addChild(wallNode)
    // 各種スプライトを生成する処理をメソッドに分割
    setupGround()
    setupCloud()
    setupWall()
    setupBird()
    setupScoreLabel()
    // アイテムを定期的に生成する処理を追加
        // アイテムを定期的に生成する
            let createItemAction = SKAction.run { [weak self] in
                self?.createItem()
            }
            let waitAction = SKAction.wait(forDuration: 4.0)  // ここで待機時間を設定
            let createItemLoopAction = SKAction.repeatForever(SKAction.sequence([createItemAction, waitAction]))

            self.run(createItemLoopAction)
        let bgmURL = Bundle.main.url(forResource: "bgm", withExtension: "mp3")!
               do {
                   audioPlayer = try AVAudioPlayer(contentsOf: bgmURL)
                   audioPlayer.numberOfLoops = -1 // 無限にループ
                   audioPlayer.play()
               } catch {
                   print("BGMファイルの読み込みに失敗しました。")
               }
        

    // itemScoreLabelNodeの初期化
    itemScoreLabelNode = SKLabelNode(fontNamed: "Helvetica")
    itemScoreLabelNode.position = CGPoint(x: 10, y: self.size.height - 30)
    itemScoreLabelNode.zPosition = 70 // 重なり順
    itemScoreLabelNode.text = "Item Score: 0"
    addChild(itemScoreLabelNode)
        
    }
    // 画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           if scrollNode.speed > 0 { // 追加
           // 鳥の速度をゼロにする
           bird.physicsBody?.velocity = CGVector.zero
           // 鳥に縦方向の力を与える
           bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 12))
           } else if bird.speed == 0 { // --- ここから ---
                      restart()
               
           }
       }
    func setupGround() {
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        // 必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        // 元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        // groundのスプライトを配置する
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            
        // スプライトの表示する位置を指定する
        sprite.position = CGPoint(
                x: groundTexture.size().width / 2  + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
        // スプライトにアクションを設定する
        sprite.run(repeatScrollGround)
            
        // スプライトに物理体を設定する
        sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())   // ←追加
            
        // 衝突のカテゴリー設定
        sprite.physicsBody?.categoryBitMask = groundCategory    // ←追加
            
        // 衝突の時に動かないように設定する
        sprite.physicsBody?.isDynamic = false   // ←追加
            
        // スプライトを追加する
        scrollNode.addChild(sprite)
        }
    }
    func setupCloud() {
        // 雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        // 必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        // スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 // 一番後ろになるようにする
        // スプライトの表示する位置を指定する
        sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )
        // スプライトにアニメーションを設定する
        sprite.run(repeatScrollCloud)
        // スプライトを追加する
        scrollNode.addChild(sprite)
        }
    }
    func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        // 移動する距離を計算
        let movingDistance = self.frame.size.width + wallTexture.size().width
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4)
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        // 2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        // 鳥が通り抜ける隙間の大きさを鳥のサイズの4倍とする
        let slit_length = birdSize.height * 4
        // 隙間位置の上下の振れ幅を60ptとする
        let random_y_range: CGFloat = 60
        // 空の中央位置(y座標)を取得
        let groundSize = SKTexture(imageNamed: "ground").size()
        let sky_center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        // 空の中央位置を基準にして下側の壁の中央位置を取得
        let under_wall_center_y = sky_center_y - slit_length / 2 - wallTexture.size().height / 2
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // アイテムを生成
               self.createItem()
            
        // 壁をまとめるノードを作成
            
        let wall = SKNode()
        wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
        wall.zPosition = -50 // 雲より手前、地面より奥
            // 下側の壁の中央位置にランダム値を足して、下側の壁の表示位置を決定する
            let random_y = CGFloat.random(in: -random_y_range...random_y_range)
            let under_wall_y = under_wall_center_y + random_y
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            // 下側の壁に物理体を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            under.physicsBody?.isDynamic = false
            
            // 壁をまとめるノードに下側の壁を追加
            wall.addChild(under)
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            // 上側の壁に物理体を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
            upper.physicsBody?.categoryBitMask = self.wallCategory    // ←追加
            upper.physicsBody?.isDynamic = false    // ←追加
            // 壁をまとめるノードに上側の壁を追加
            wall.addChild(upper)
            
            // スコアカウント用の透明な壁を作成
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)

            // 透明な壁に物理体を設定する
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.isDynamic = false

            // 壁をまとめるノードに透明な壁を追加
            wall.addChild(scoreNode)
                       
            // 壁をまとめるノードにアニメーションを設定
            wall.run(wallAnimation)
            // 壁を表示するノードに今回作成した壁を追加
            self.wallNode.addChild(wall)
        })
        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        // // 壁を表示するノードに壁の作成を無限に繰り返すアクションを設定
        wallNode.run(repeatForeverAnimation)
    }
    func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
            let birdTextureB = SKTexture(imageNamed: "bird_b")
            
            birdTextureA.filteringMode = .linear
            birdTextureB.filteringMode = .linear
       
        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
           if bird == nil {
               print("Bird could not be created.")
               return
           }
        bird.zPosition = 3  // アイテムとの処理のためzPosition を設定
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        // 物理体を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)    // ←追加
        // カテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory    // ←追加
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory    // ←追加
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory|scoreCategory
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false    // ←追加
        // アニメーションを設定
        bird.run(flap)
        // スプライトを追加する
        addChild(bird)
    }
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない
        if scrollNode.speed <= 0 {
            return
        }

        // スコア用の透明な壁と衝突した場合
            if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory ||
               (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
                print("ScoreUp by wall")
                score += 1
                scoreLabelNode.text = "Score:\(score)"

                // ベストスコア更新か確認する
                var bestScore = userDefaults.integer(forKey: "BEST")
                if score > bestScore {
                    bestScore = score
                    bestScoreLabelNode.text = "Best Score:\(bestScore)"
                    userDefaults.set(bestScore, forKey: "BEST")
                }
            }
            // アイテムと衝突した場合
            else if (contact.bodyA.categoryBitMask == birdCategory && contact.bodyB.categoryBitMask == itemCategory) ||
                    (contact.bodyA.categoryBitMask == itemCategory && contact.bodyB.categoryBitMask == birdCategory) {
                print("Item Collected")
                score += 1
                scoreLabelNode.text = "Score:\(score)"

            // アイテム取得音を出す
            let soundAction = SKAction.playSoundFileNamed("決定ボタンを押す26.mp3", waitForCompletion: false)
            run(soundAction)
            
            // アイテムを削除
            if contact.bodyA.categoryBitMask == itemCategory {
                contact.bodyA.node?.removeFromParent()
            }
            if contact.bodyB.categoryBitMask == itemCategory {
                contact.bodyB.node?.removeFromParent()
            }
            
            // ベストアイテムスコア更新か確認する
            var bestItemScore = userDefaults.integer(forKey: "BEST_ITEM_SCORE")
            if itemScore > bestItemScore {
                bestItemScore = itemScore
                bestScoreLabelNode.text = "Best Item Score:\(bestItemScore)"
                userDefaults.set(bestItemScore, forKey: "BEST_ITEM_SCORE")
            }
        }
        // 壁か地面と衝突した場合
        else {
            gameOver()

            print("GameOver")
            // スクロールを停止
            scrollNode.speed = 0
            
            
            // 衝突後は地面と反発するのみ
            bird.physicsBody?.collisionBitMask = groundCategory

            // 鳥が回転する時間を計算
            let duration = bird.position.y / 400.0 + 1.0
            let roll = SKAction.rotate(byAngle: 2.0 * Double.pi * duration, duration: duration)
            bird.run(roll, completion: {
                self.bird.speed = 0
            })
        }         
}
  
    func setupScoreLabel() {
           // スコア表示を作成
           score = 0
           scoreLabelNode = SKLabelNode()
           scoreLabelNode.fontColor = UIColor.black
           scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
           scoreLabelNode.zPosition = 100 // 一番手前に表示する
           scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
           scoreLabelNode.text = "Score:\(score)"
           self.addChild(scoreLabelNode)

           // ベストスコア表示を作成
           let bestScore = userDefaults.integer(forKey: "BEST")
           bestScoreLabelNode = SKLabelNode()
           bestScoreLabelNode.fontColor = UIColor.black
           bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
           bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
           bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
           bestScoreLabelNode.text = "Best Score:\(bestScore)"
           self.addChild(bestScoreLabelNode)
       }
    func setupItemScoreLabel() {
        itemScoreLabelNode = SKLabelNode(fontNamed: "Helvetica")
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        itemScoreLabelNode.zPosition = 100 // なるべく手前に表示する
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "Item Score:\(itemScore)"
        self.addChild(itemScoreLabelNode)
    
    }
func createItem() {
        // アイテムの画像を読み込む
        let itemImage = SKTexture(imageNamed: "item")
        itemImage.filteringMode = .linear

        // SKSpriteNodeを作成
        let item = SKSpriteNode(texture: itemImage)
        item.size = CGSize(width: item.size.width * 0.025, height: item.size.height * 0.025)
        item.zPosition = -60

        // 画面の右端にアイテムを配置
           let initialX = self.frame.size.width + item.size.width / 2
           let centerY = self.size.height / 2.0
           let heightOffsets: [CGFloat] = [-0.2, 0.12, 0.25]
           let randomIndex = Int(arc4random_uniform(UInt32(heightOffsets.count)))
           let yOffset = self.size.height * heightOffsets[randomIndex]  // ランダムにオフセットを選ぶ
           let itemY = centerY + yOffset        // 選んだオフセットでy座標を調整

           item.position = CGPoint(x: initialX, y: itemY)
        // PhysicsBodyを設定
        item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.width / 3.8)
        item.physicsBody?.categoryBitMask = itemCategory
        item.physicsBody?.contactTestBitMask = birdCategory
        item.physicsBody?.collisionBitMask = 0
        item.physicsBody?.affectedByGravity = false

        // アイテムが動く距離を計算
        let itemMovingDistance = self.frame.size.width + item.size.width
        // 画面外まで移動するアクションを作成
        let moveItem = SKAction.moveBy(x: -itemMovingDistance, y: 0, duration:4)

        // 自身を取り除くアクションを作成
        let removeItem = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let itemSequence = SKAction.sequence([moveItem, removeItem])
        // シーンに追加
        addChild(item)
        // アイテムに対してシーケンスを実行する
    item.run(itemSequence)  // これが欠けている可能性があります
       
        }
    
func gameOver() {
        print("Game Over function called")
        if let player = audioPlayer {
            player.stop()
        }

          // スクロールを停止させる
          self.scrollNode.speed = 0
          // "spawnLoop"アクションを停止
          self.removeAction(forKey: "spawnLoop")

          // すべてのアイテムを削除
          self.enumerateChildNodes(withName: "item") { (node, stop) in
              node.removeFromParent()
        }
}
    
func restart() {
    audioPlayer?.play()  // ?を使ってnilでない場合のみplay()を呼び出す
    // spawnLoopを再生成
    let spawn = SKAction.run { [weak self] in
        self?.createItem() // アイテムを生成する実際の関数に置き換えました
    }
    let wait = SKAction.wait(forDuration: 2.0)
    let spawnSequence = SKAction.sequence([spawn, wait])
    let spawnLoop = SKAction.repeatForever(spawnSequence)

    // spawnLoopを再開
    run(spawnLoop, withKey: "spawnLoop")

    // スコアとアイテムスコアをリセット
    score = 0
    itemScore = 0
    // スコア表示を更新
    scoreLabelNode.text = "Score: \(score)"
    itemScoreLabelNode.text = "Item Score: \(itemScore)"

    // 鳥を初期位置に戻し、壁と地面の両方に反発するように戻す
    bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.9)
    bird.physicsBody?.velocity = CGVector.zero
    bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
    bird.zRotation = 0
    // 全ての壁を取り除く
    wallNode.removeAllChildren()
    // 鳥の羽ばたきを戻す
    bird.speed = 1
    // スクロールを再開させる
    scrollNode.speed = 1
    // BGMを再開
           audioPlayer.play()
   }
}
    
