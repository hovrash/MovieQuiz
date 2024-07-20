import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
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
        previewImage.layer.masksToBounds = true
        previewImage.layer.cornerRadius = 20
        showLoadingIndicator()
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
    
    func show(quiz step: QuizStepViewModel) {
        buttonsEnableToggle(true)
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        questionLabel.text = step.question
    }
    
    // MARK: - Private Methods
    func buttonsEnableToggle(_ action: Bool) {
        noButton.isEnabled = action
        yesButton.isEnabled = action
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
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
}
