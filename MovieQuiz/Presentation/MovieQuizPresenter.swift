//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Timur Tufatulin on 19/07/2024.
//

import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    let staticsService = StatisticService()
    private var currentQuestionIndex: Int = 0
    weak var viewController: MovieQuizViewController?
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int?
    var questionFactory: QuestionFactoryProtocol?
    
    func yesButtonTap() {
        viewController?.showAnswerResult(isCorrect: true)
    }
    
    func noButtonTap() {
        viewController?.showAnswerResult(isCorrect: false)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
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
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            guard let correctAnswers = viewController?.correctAnswers else { return }
            guard let questionFactory = viewController?.questionFactory else { return }
            
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
}
