//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Timur Tufatulin on 22/06/2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion: () -> ()
}
