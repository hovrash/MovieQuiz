//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Timur Tufatulin on 23/06/2024.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(game: GameResult)
    
    func showRecord () -> String
}
