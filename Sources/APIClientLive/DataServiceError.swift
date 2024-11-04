import Foundation

enum DataServiceError: Error, LocalizedError {
    case fileNotFound(filename: String)
    case dataLoadingFailed(filename: String)
    case dataDecodingFailed(filename: String, error: Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "Error: Could not find file \(filename).json in the bundle."
        case .dataLoadingFailed(let filename):
            return "Error: Could not load data from file \(filename).json."
        case .dataDecodingFailed(let filename, let error):
            return "Error: Could not decode data from file \(filename).json. \(error.localizedDescription)"
        }
    }
}
