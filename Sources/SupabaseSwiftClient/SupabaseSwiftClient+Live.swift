import Dependencies
import DependenciesMacros
import Foundation
import Supabase
import SwiftHelpers

public enum SupabaseAuthError: Error {
    case noSession
}

extension SupabaseAuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noSession:
            "Unable to retrieve current session. Please try again."
        }
    }
}

extension SupabaseSwiftClient: DependencyKey {
    public static var liveValue: SupabaseSwiftClient {
        let supabase = SupabaseClient(
            // swiftlint:disable:next force_unwrapping
            supabaseURL: URL(string: "https://mfzcojdomumihvxmzuwk.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1memNvamRvbXVtaWh2eG16dXdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ1NzA0MjEsImV4cCI6MjA2MDE0NjQyMX0.fiInimC7sMPQsUFNb5sDl3ua-ZiTO04LAkGtekA_p-g"
        )

        return SupabaseSwiftClient(
            signInWithIdToken: { credential in
                try await supabase.auth.signInWithIdToken(credentials: credential)
            },
            signIn: { email, password in
                try await supabase.auth.signIn(email: email, password: password)
            },
            signUp: { email, password in
                let result = try await supabase.auth.signUp(email: email, password: password)
                guard let session = result.session else {
                    throw SupabaseAuthError.noSession
                }
                return session
            },
            signOut: {
                try await supabase.auth.signOut()
            },
            handle: { url in
                supabase.auth.handle(url)
                return true
            }
        )
    }
}
