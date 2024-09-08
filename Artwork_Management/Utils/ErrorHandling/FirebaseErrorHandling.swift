//
//  ErrorHandling.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/23.
//

protocol FirebaseErrorHandling {
    var showErrorAlert: Bool { get set }
    var errorMessage: String { get set }
    func handleErrors(_ errors: [Error])
}

extension FirebaseErrorHandling {
    func handleErrors(_ errors: [Error]) {
        if errors.isEmpty { return }

        let messages = errors.map { error -> String in

            if let error = error as? FirestoreError {
                return error.localizedDescription

            } else if let error = error as? FirebaseStorageError {
                return error.localizedDescription

            } else {
                return "未知のエラー: \(error.localizedDescription)"
            }

        }.joined(separator: "\n")

        Logger.e(messages)
    }
}
