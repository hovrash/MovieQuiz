//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Timur Tufatulin on 22/06/2024.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    func prepareAlert (result: AlertModel) {
        let newAlert = AlertModel(title: result.title, message: result.message, buttonText: result.buttonText, completion: {})
        delegate?.showAlert(newAlert: newAlert)
    }
}
