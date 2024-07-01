//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Timur Tufatulin on 23/06/2024.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetter(than: GameResult) -> Bool {
        correct > than.correct
    }
}

