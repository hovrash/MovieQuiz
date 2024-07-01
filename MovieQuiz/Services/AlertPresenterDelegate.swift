//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Timur Tufatulin on 22/06/2024.
//

import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func showAlert(newAlert: AlertModel)
}
