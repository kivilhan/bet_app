import Foundation
import CryptoKit

// MARK: - Nonce Utilities
func randomNonceString(length: Int = 32) -> String {
    let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        let randoms = (0..<16).map { _ in UInt8.random(in: 0...255) }

        for random in randoms {
            if remainingLength == 0 {
                break
            }

            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }

    return result
}

func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.map { String(format: "%02x", $0) }.joined()
}

enum AuthState {
    case authenticated
    case unauthenticated
}

struct LeaderboardEntry: Identifiable {
    let id: String  // user ID
    let username: String
    let totalBetbucks: Int
}
