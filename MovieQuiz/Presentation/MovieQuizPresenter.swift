//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Timur Tufatulin on 19/07/2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol!
    private var currentQuestionIndex: Int = 0
    private weak var viewController: MovieQuizViewController?
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        statisticService = StatisticService()
        self.viewController = viewController as? MovieQuizViewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func yesButtonTap() {
        proceedWithAnswer(isCorrect: true)
    }
    
    func noButtonTap() {
        proceedWithAnswer(isCorrect: false)
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
    
    func didAnswer(isCorrect: Bool) -> Bool {
        if isCorrect == currentQuestion?.correctAnswer {
            correctAnswers += 1
            return true
        } else {
            return false
        }
    }
    
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let gameResult = GameResult(correct: correctAnswers, total: self.questionsAmount, date: Date())
            let text = makeResultsMessage(game: gameResult)
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
    
    func makeResultsMessage(game: GameResult) -> String {
        statisticService.store(game: game)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        viewController?.buttonsEnableToggle(false)
        viewController?.highlightImageBorder(isCorrectAnswer: didAnswer(isCorrect: isCorrect))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.proceedToNextQuestionOrResults()
        }
    }
}
