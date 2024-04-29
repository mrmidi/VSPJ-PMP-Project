 import Foundation
 import SwiftData
 import Combine


class DataLoader {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadJSONData<T: Codable & Identifiable>(resourceName: String, type: T.Type) async throws {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
//            throw MyVSPJParseError.fileNotFound(resourceName)
            return
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode([T].self, from: data)

        // Insert each decoded item into the model
        for item in decodedData {
            print("Item: \(item)")
//            modelContext.insert(item)
        }
    }
}
