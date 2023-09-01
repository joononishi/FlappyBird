
import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SKViewに型を変換する
        let skView = self.view as! SKView

        // FPSを表示する 1秒間に何回更新されているかを示すFPSを画面の右下に表示させる
        skView.showsFPS = true

        // ノードの数を表示する プロパティはノードが幾つ表示されているかを画面の右下に表示させるもの
        skView.showsNodeCount = true

        // ビューと同じサイズでシーンを作成する
        let scene = GameScene(size:skView.frame.size) // ←GameSceneクラスに変更する

        // ビューにシーンを表示する SKSceneはSKViewクラスのpresentScene()メソッドで設定
        skView.presentScene(scene)
          }
    
    // ステータスバーを消す
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
}



