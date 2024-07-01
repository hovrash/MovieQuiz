import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private var indexLabel: UILabel!
    @IBOutlet private var previewImage: UIImageView!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    // MARK: - Private Properties
    private var currentQuestionIndex = 0 // индекс текущего вопроса
    private var correctAnswers = 0 // количество правильных ответов
    private let questionsAmount: Int = 10 // общее количество вопросов для квиза
    private var questionFactory: QuestionFactoryProtocol? // фабрика вопросов
    private var currentQuestion: QuizQuestion? // текущий вопрос, который видит пользователь
    private var staticsService: StatisticServiceProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        let staticsService = StatisticService()// создаем свойство для ведения статистики
        self.staticsService = staticsService
        let questionFactory = QuestionFactory() // создаем экземпляр фабрики для её настройки
        questionFactory.delegate = self // устанавливаем связь фабрики с делегатом
        self.questionFactory = questionFactory // сохраняем подготовленный экземпляр свойство контроллера
        previewImage.layer.masksToBounds = true
        previewImage.layer.cornerRadius = 20
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - AlertPresenterDelegate
    func showAlert(newAlert: AlertModel) {
        previewImage.layer.borderWidth = 0
        var alertWithAction = newAlert
        alertWithAction.completion = {
            let alert = UIAlertController(
                title: newAlert.title,
                message: newAlert.message,
                preferredStyle: .alert)
            let action = UIAlertAction(title: newAlert.buttonText, style: .default) { [weak self] _ in
                guard let self = self else {return}
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                questionFactory?.requestNextQuestion()
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        alertWithAction.completion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonTap(_ sender: Any) {
        showAnswerResult(isCorrect: false) // отправляем в метод showAnswerResult значение false
    }
    @IBAction private func yesButtonTap(_ sender: Any) {
        showAnswerResult(isCorrect: true) // отправляем в метод showAnswerResult значение true
    }
    
    // MARK: - Private Methods
    // метод, который принимает булевое значение от кнопок, управляет доступностью кнопок
    private func ButtonsEnableToggle(_ action: Bool) {
        noButton.isEnabled = action
        yesButton.isEnabled = action
    }
    
    // метод, который конвертирует модель вопроса для показа на экране
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let result = QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return result
    }

    // метод показа следующего вопроса
    private func show(quiz step: QuizStepViewModel) {
        ButtonsEnableToggle(true)
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        questionLabel.text = step.question
    }
    
    // метод показа правильности ответа (рамка зелёная или красная)
    private func showAnswerResult(isCorrect: Bool) {
        guard let currentQuestion = currentQuestion else {return}
        previewImage.layer.borderWidth = 8
        ButtonsEnableToggle(false)
        if currentQuestion.correctAnswer == isCorrect {
            previewImage.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            previewImage.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
        }
    }
    
    // метод, который либо вызывает функцию следующего вопроса, либо функцию показа алерта
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let gameResult = GameResult(correct: correctAnswers, total: questionsAmount, date: Date())
            //let staticsService = StatisticService()
            guard let staticsService = staticsService else {return}
            staticsService.store(game: gameResult)
            let text = """
                            Ваш результат: \(correctAnswers)/\(questionsAmount)
                            Количество сыгранных квизов: \(staticsService.gamesCount)
                            Рекорд: \(staticsService.showRecord())
                            Средняя точность: \(String(format: "%.2f", staticsService.totalAccuracy))%
                       """
            let quizResult = AlertModel(title: "Этот раунд закончен!", message: text, buttonText: "Сыграть ещё раз", completion:{})
            alertPresenter?.prepareAlert(result: quizResult)
        } else {
            previewImage.layer.borderWidth = 0
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}
