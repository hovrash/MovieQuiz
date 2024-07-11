//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Timur Tufatulin on 21/06/2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
