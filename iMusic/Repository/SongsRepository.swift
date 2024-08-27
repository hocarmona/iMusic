//
//  SongsRepository.swift
//  iMusic
//
//  Created by Hector Carmona on 8/26/24.
//

import Foundation

class SongsRepository {
    func fetchAllSongs() -> [Song] {
        return [
            Song(name: "Sixteen"),
            Song(name: "perfecta"),
            Song(name: "seraPorqueTeAmo"),
            Song(name: "laFuerzaDelDestino"),
            Song(name: "aQuiénLeImporta")
        ]
    }
}
