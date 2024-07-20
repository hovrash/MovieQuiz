import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    // MARK: - IB Outlets
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    // MARK: - Public Properties
    var alertPresenter: AlertPresenterProtocol?
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
//        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self) // создаем экземпляр фабрики для её настройки
        //questionFactory.delegate = self // устанавливаем связь фабрики с делегатом
//        self.questionFactory = questionFactory // сохраняем подготовленный экземпляр свойство контроллера
        previewImage.layer.masksToBounds = true
        previewImage.layer.cornerRadius = 20
        showLoadingIndicator()
//        questionFactory.loadData()
//        questionFactory.requestNextQuestion()
//        presenter.viewController = self
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonTap(_ sender: Any) {
        presenter.noButtonTap()
    }
    @IBAction private func yesButtonTap(_ sender: UIButton) {
        presenter.yesButtonTap()
    }
    
    //MARK: - Public Methods
    func showAlert(newAlert: AlertModel) {
        previewImage.layer.borderWidth = 0
        var alertWithAction = newAlert
        alertWithAction.completion = {
            let alert = UIAlertController(
                title: newAlert.title,
                message: newAlert.message,
                preferredStyle: .alert)
            alert.view.accessibilityIdentifier = "Alert"
            let action = UIAlertAction(title: newAlert.buttonText, style: .default) { [weak self] _ in
                guard let self = self else {return}
                self.presenter.restartGame()
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        alertWithAction.completion()
    }
    
//    func didLoadDataFromServer() {
//        activityIndicator.isHidden = true
//        questionFactory?.requestNextQuestion()
//    }
//    
//    func didFailToLoadData(with error: any Error) {
//        showNetworkError(message: error.localizedDescription)
//    }
//    
//    func didReceiveNextQuestion(question: QuizQuestion?) {
//        presenter.didReceiveNextQuestion(question: question)
//    }
    
    func show(quiz step: QuizStepViewModel) {
        ButtonsEnableToggle(true)
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        questionLabel.text = step.question
    }
    
    // MARK: - Private Methods
    private func ButtonsEnableToggle(_ action: Bool) {
        noButton.isEnabled = action
        yesButton.isEnabled = action
    }
    
    func showAnswerResult(isCorrect: Bool) {
        guard let currentQuestion = presenter.currentQuestion else {return}
        previewImage.layer.borderWidth = 8
        ButtonsEnableToggle(false)
        if currentQuestion.correctAnswer == isCorrect {
            previewImage.layer.borderColor = UIColor.ypGreen.cgColor
            presenter.didAnswer(isCorrect: isCorrect)
        } else {
            previewImage.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertTitle = "Ошибка"
        let textButton = "Попробовать ещё раз"
        let errorAlert = AlertModel(title: alertTitle, message: message, buttonText: textButton) {
            [weak self] in
            guard let self = self else { return }
            presenter.restartGame()
        }
        alertPresenter?.prepareAlert(result: errorAlert)
    }
    
    func showLoadingIndicator() {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}
