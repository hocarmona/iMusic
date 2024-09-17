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
            Song(name: "JoshWoodward-DW-03-Insomnia"),
            Song(name: "JoshWoodward-DW-07-TheRavenAndTheSwan"),
            Song(name: "aQuiénLeImporta"),
            Song(name: "Sixteen"),
            Song(name: "perfecta"),
            Song(name: "seraPorqueTeAmo"),
            Song(name: "laFuerzaDelDestino"),
        ]
    }
}
