import Foundation

struct Player: Equatable {
    var name: String = "Player One"
    var score: Int = 1

    mutating func bumpScore() {
        score += 1
    }

    mutating func changeName(to number: Int) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        let playerNumber = formatter.string(from: number as NSNumber)
            .map { $0.prefix(1).capitalized + $0.dropFirst() } ?? "One"

        name = "Player \(playerNumber)"
    }
}
