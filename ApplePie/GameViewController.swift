import UIKit

class GameViewController: UIViewController {
    
    var totalWins: Int = 0
    var totalLosses: Int = 0
    
    var words: [String] = []
    var chractersInWord: [String] = []
    var charactersInGuess: [String] = [] {
        // 當答案改變時自動更新顯示的答案標籤
        didSet {
            answerLabel.text = charactersInGuess.joined(separator: " ")
        }
    }
    var numberOfLife: Int = 7 {
        // 當剩餘次數改變時自動變更蘋果數目的圖片
        didSet {
            treeImageView.image = UIImage(named: "appleTree-\(numberOfLife)")
        }
    }
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var treeImageView: UIImageView!
    @IBOutlet var answerLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var tryAgainButton: UIButton!
    @IBOutlet var letterButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 設定專案預設字型
        UILabel.appearance().substituteFontName = "Mali-Medium"
        // 設定字母按鈕圓角
        for letterButton in letterButtons {
            letterButton.clipsToBounds = true
            letterButton.layer.cornerRadius = 5
        }
        // 準備單字array
        guard let path = Bundle.main.path(forResource: "words", ofType: "csv") else {
            print("No csv file found.")
            return
        }
        do {
            let csvData = try String(contentsOfFile: path)
            words = csvData.components(separatedBy: .newlines)
            words.removeAll(where: {$0 == ""})
        } catch let error as NSError {
            print(error)
            return
        }
        newGame()
    }

    @IBAction func letterButtonPressed(_ sender: UIButton) {
        // 按過的字母不能再按
        sender.isEnabled = false
        sender.backgroundColor = .systemGray
        
        // 判斷所選取字母是否包含在單字中的變數，初始值設為否
        var charInWord: Bool = false
        
        if let letter = sender.title(for: .normal)?.lowercased() {
            // 逐一確認使用者選擇的字母是否有出現在答案中
            for (index, char) in chractersInWord.enumerated() {
                if letter == char {
                    charInWord = true
                    // 顯示猜中的字母
                    charactersInGuess[index] = letter
                    // 判斷是否已猜完全部字母，如果是則結束遊戲
                    if charactersInGuess == chractersInWord {
                        win()
                    }
                }
            }
            if !charInWord {
                self.numberOfLife -= 1
                treeImageView.image = UIImage(named: "appleTree-\(numberOfLife)")
                // 判斷是否用光所有次數，如果是則結束遊戲
                if numberOfLife == 0 {
                    lose()
                }
            }
        }
    }
    
    @IBAction func tryAgainButtonPressed(_ sender: Any) {
        newGame()
    }
    
    
    func newGame() {
        // 更新顯示分數及將按鈕設定為遊戲執行時的狀態
        updateUI()
        // 重設剩餘次數
        numberOfLife = 7
        // 隨機選取一個單字
        let randomWord = words.randomElement()?.lowercased() ?? "apple"
        print(randomWord)
        // 將單字轉換成array
        chractersInWord = []
        for char in randomWord {
            chractersInWord.append(String(char))
        }
        // 使用者輸入答案的array
        charactersInGuess = Array(repeating: "_", count: chractersInWord.count)
    }
    
    func updateUI() {
        // 更新分數標籤
        scoreLabel.text = "Wins: \(totalWins), Losses: \(totalLosses)"
        // 重設答案標籤顏色
        answerLabel.backgroundColor = UIColor(named: "labelColor")
        // 隱藏遊戲結束後選項
        resultLabel.isHidden = true
        tryAgainButton.isHidden = true
        // 啟用字母按鈕及變更按鈕顏色
        for button in letterButtons {
            button.isEnabled = true
            button.backgroundColor = UIColor(named: "keyboardColor")
        }
    }
    
    func lose() {
        totalLosses += 1
        resultLabel.text = "You lose"
        // 顯示答案並變更標籤顏色為紅色
        charactersInGuess = chractersInWord
        answerLabel.backgroundColor = UIColor(named: "red")
        gameOver()
    }
    
    func win() {
        totalWins += 1
        resultLabel.text = "You win"
        gameOver()
    }
    
    func gameOver() {
        // 關閉字母按鈕功能
        for button in letterButtons {
            button.isEnabled = false
        }
        // 顯示結果標籤和重來按鈕
        resultLabel.isHidden = false
        tryAgainButton.isHidden = false
    }
    
}

extension UILabel {
    // 設定專案預設字型
    @objc var substituteFontName : String {
        get { return self.font.fontName }
        set { self.font = UIFont(name: "Mali-Medium", size: self.font.pointSize) }
    }
}
