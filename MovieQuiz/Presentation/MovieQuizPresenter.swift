//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Timur Tufatulin on 19/07/2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    let staticsService = StatisticService()
    private var currentQuestionIndex: Int = 0
    private weak var viewController: MovieQuizViewController?
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func yesButtonTap() {
        viewController?.showAnswerResult(isCorrect: true)
    }
    
    func noButtonTap() {
        viewController?.showAnswerResult(isCorrect: false)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let result = QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                       question: model.text,
                                       questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return result
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {            
            let gameResult = GameResult(correct: correctAnswers, total: self.questionsAmount, date: Date())
            staticsService.store(game: gameResult)
            let text = """
                            Ваш результат: \(correctAnswers)/\(self.questionsAmount)
                            Количество сыгранных квизов: \(staticsService.gamesCount)
                            Рекорд: \(staticsService.showRecord())
                            Средняя точность: \(String(format: "%.2f", staticsService.totalAccuracy))%
                       """
            let quizResult = AlertModel(title: "Этот раунд закончен!", message: text, buttonText: "Сыграть ещё раз", completion:{})
            viewController?.alertPresenter?.prepareAlert(result: quizResult)
        } else {
            viewController?.previewImage.layer.borderWidth = 0
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
}
