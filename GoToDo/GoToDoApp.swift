//
//  GoToDoApp.swift
//  GoToDo
//
//  Created by Артeмий Шлесберг on 06.04.2022.
//

import SwiftUI

@main
struct GoToDoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
