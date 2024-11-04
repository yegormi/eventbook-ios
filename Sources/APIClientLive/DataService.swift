import Foundation

class DataService {
    static let shared = DataService()
    
    func loadMockData<T: Decodable>(filename: String, type: T.Type) async throws -> T {
        guard let url = Bundle.module.url(forResource: filename, withExtension: "json") else {
            throw DataServiceError.fileNotFound(filename: filename)
        }
        
        do {
            let data = try await loadData(from: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                return try ISO8601DateTranscoderWithFractions().decode(dateString)
            }
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch let decodingError as DecodingError {
            throw DataServiceError.dataDecodingFailed(filename: filename, error: decodingError)
        } catch {
            throw DataServiceError.dataLoadingFailed(filename: filename)
        }
    }
    
    private func loadData(from url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let data = try Data(contentsOf: url)
                continuation.resume(returning: data)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
