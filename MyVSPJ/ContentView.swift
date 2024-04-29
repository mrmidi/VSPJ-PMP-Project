//
//  ContentView.swift
//  MyVSPJ
//
//  Created by Alexander Shabelnikov on 26.04.2024.
//

import SwiftUI
import SwiftData

struct SplashView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isLoading = true
    @Query private var courses: [Course]
    @State private var courseCount = 0
    //    @FetchRequest private var courseFetchDesciptor: FetchRequest<Course>
    
    var body: some View {
        if isLoading {
            VStack {
                if isLoading {
                    Spacer()
                    Image("logo_20_bez_pozadi") // Use the custom image from the asset catalog
                        .resizable() // Make the image resizable
                        .aspectRatio(contentMode: .fit) // Maintain the aspect ratio of the image
                        .frame(width: 200, height: 200) // Set a fixed size for the image
                        .clipped() // Clip the image to the frame
                        .foregroundColor(.gray) // Set the foreground color (not applicable to custom images)
                    Text("Loading...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .onAppear {
                Task {
                    countCourses()
                    do {
                        
                        if courseCount == 0 {
                            try await loadJSON(resourceName: "courses", type: Course.self)
                            try await loadJSON(resourceName: "completiontypes", type: CompletionType.self)
                            try await loadJSON(resourceName: "coursetypes", type: CourseType.self)
                            try await loadJSON(resourceName: "coursecompletionstats", type: CourseCompletionStat.self)
                            try await loadJSON(resourceName: "coursedetails", type: CourseDetail.self)
                            try await loadJSON(resourceName: "departments", type: Department.self)
                        }
                        
                        
                        
                        // Simulate delay
                        try await Task.sleep(nanoseconds: 3_000_000_000) // 10 seconds
                        
                        DispatchQueue.main.async {
                            isLoading = false // Change state to trigger UI update after all operations
                        }
                    } catch {
                        print("Error loading data!")
                    }
                }
            }
        }
        
        // Transition to the main view
        if !isLoading {
            MainView()
        }
    }
    
    private func countCourses() {
        // fetch number of corses in DB
        let countDescriptor = FetchDescriptor<Course>()
        let countCourses = try modelContext.fetch(countDescriptor).count
    }
    
    func loadJSON<T: Decodable & Identifiable & PersistentModel>(resourceName: String, type: T.Type) async throws {
        print ("Loading \(resourceName)...")
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
            throw MyVSPJParseError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode([T].self, from: data)
        
        // Insert each decoded item into the model
        for item in decodedData {
            print("Item: \(item)")
            modelContext.insert(item)
        }
    }
    
    enum MyVSPJParseError: Error {
        case fileNotFound
    }
    
    
}

#Preview {
    SplashView()
    // .modelContainer(for: Item.self, inMemory: true)
}
