//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Timur Tufatulin on 19/07/2024.
//

import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    weak var viewController: MovieQuizViewController?
    
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
}
