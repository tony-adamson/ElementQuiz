//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Антон Адамсон on 09.02.2023.
//


import UIKit

enum Mode {
    case flashCard
    case quiz
}

enum State {
    case question
    case answer
    case score
}

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var showAnswerButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mode = .flashCard
    }

    var elementList: [String] = []
    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    
    var currentElementIndex = 0
    
    //обновляет интерфейс в режиме тренировки
    func updateFlashCardUI(elementName: String) {
        //отключает ненужные элементы интерфейса: текстовое поле и клавиатуру
        textField.isHidden = true
        textField.resignFirstResponder()
        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
        
        // работа с полем для показа ответа
        if state == .answer {
            answerLabel.text = elementName
        } else {
            answerLabel.text = "?"
        }
        modeSelector.selectedSegmentIndex = 0
    }
    
    //обновляет интерфейс в режиме викторины
    func updateQuizUI(elementName: String) {
        //включение текстового поля и кейс для клавиатуры
        textField.isHidden = false
        switch state {
        case .question:
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer:
            textField.isEnabled = false
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }
        
        showAnswerButton.isHidden = true
        if currentElementIndex == elementList.count - 1 {
            nextButton.setTitle("Show Score", for: .normal)
        } else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        
        switch state {
        case .question:
            nextButton.isEnabled = false
        case .answer:
            nextButton.isEnabled = true
        case .score:
            nextButton.isEnabled = false
        }
        
        switch state {
        case .question:
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer:
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }
        
        //работа с заголовком через кейсы
        switch state {
        case .question:
            answerLabel.text = ""
        case .answer:
            if answerIsCorrect == true {
                answerLabel.text = "Correct!"
            } else {
                answerLabel.text = "❌\nCorrect Answer: " + elementName
            }
        case .score:
            answerLabel.text = ""
        }
        
        if state == .score {
            displayScoreAlert()
        }
        
        modeSelector.selectedSegmentIndex = 1
    }
    
    //главная функция для работы приложения
    func updateUI() {
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        switch mode {
        case .flashCard:
            updateFlashCardUI(elementName: elementName)
        case .quiz:
            updateQuizUI(elementName: elementName)
        }
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        state = .answer
        updateUI()
    }
    
    @IBAction func next(_ sender: Any) {
        currentElementIndex += 1
        if currentElementIndex >= elementList.count {
            currentElementIndex = 0
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        }
        state = .question
        updateUI()
    }
    
    var mode: Mode = .flashCard {
        didSet {
            switch mode {
            case .flashCard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }
            updateUI()
        }
    }
    var state: State = .question
    var answerIsCorrect = false
    var correctAnswerCount = 0
    
    //функция для определения правильного ответа
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFielsContents = textField.text!
        
        if textFielsContents.lowercased() == elementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }
        state = .answer
        updateUI()
        return true
    }
    
    @IBAction func switchModes(_ sender: Any) {
        if modeSelector.selectedSegmentIndex == 0 {
            mode = .flashCard
        } else {
            mode = .quiz
        }
    }
    
    //функция для показа предупреждений
    func displayScoreAlert() {
        let alert =
            UIAlertController(title: "Quiz Score:",
                              message: "you score is \(correctAnswerCount) out of \(elementList.count)",
                              preferredStyle: .alert)
                                      
        let dismissAction =
            UIAlertAction(title: "OK",
                          style: .default,
                          handler: scoreAlertDismissed(_:))
                                      
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
                                      
    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashCard
    }
    
    func setupFlashCards() {
        elementList = fixedElementList
        currentElementIndex = 0
        state = .question
    }
    
    func setupQuiz() {
        elementList = fixedElementList.shuffled()
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
    }
}
