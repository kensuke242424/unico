//
//  FirestoreSerializable.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/16.
//

protocol FirestoreSerializable {
    var id: String { get }
    func firestorePath() -> FirestorePath
}
