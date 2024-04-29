//
//  MyVSPJApp.swift
//  MyVSPJ
//
//  Created by Alexander Shabelnikov on 26.04.2024.
//

import SwiftUI
import SwiftData

@main
@MainActor
struct MyVSPJApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Department.self,
            CourseType.self,
            CourseCompletionStat.self,
            Course.self,
            CourseDetail.self,
            CompletionType.self,
            StudyPlan.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // display the splash view while loading data
    var body: some Scene {
        WindowGroup {
            SplashView()
                .modelContainer(sharedModelContainer)
        }
    }
    
    


}


