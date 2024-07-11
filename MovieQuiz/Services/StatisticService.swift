//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Timur Tufatulin on 23/06/2024.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.setValue(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let bestGameResult = GameResult(
                correct: storage.integer(forKey: Keys.bestGameCorrect.rawValue),
                total: storage.integer(forKey: Keys.bestGameTotal.rawValue),
                date: storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            )
            return bestGameResult
        }
        set{
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        return Double(correctAnswers) / (10 * Double(gamesCount)) * 100
    }
    
    private let storage: UserDefaults = .standard
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case correctAnswers
    }
    
    func store(game: GameResult) {
        gamesCount += 1
        correctAnswers += game.correct
        if !bestGame.isBetter(than: game) {
            bestGame = game
        }
    }
    
    func showRecord () -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd.MM.yyyy HH:mm"
        let stringDate = dateFormat.string(from: bestGame.date)
        return "\(bestGame.correct)/\(bestGame.total) (\(stringDate))"
    }
}

