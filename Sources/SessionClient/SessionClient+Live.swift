@preconcurrency import Combine
import Dependencies
import FacebookClient
import GoogleClient
import KeychainClient
import SharedModels
import SupabaseSwiftClient

extension SessionClient: DependencyKey {
    public static var liveValue: SessionClient {
        struct Storage {
            var currentUser: User?
            var currentAccessToken: String?
        }

        let storage = LockIsolated(Storage())
        let subject = PassthroughSubject<User?, Never>()

        @Dependency(\.keychain) var keychain
        @Dependency(\.authGoogle) var google
        @Dependency(\.authFacebook) var facebook
        @Dependency(\.supabaseClient) var supabase

        return Self(
            authenticate: { user in
                storage.withValue { $0.currentUser = user }
                subject.send(user)
            },
            setCurrentAccessToken: { token in
                storage.withValue { $0.currentAccessToken = token }
                try keychain.set(.appAccessToken, to: token)
            },
            currentAccessToken: {
                guard let token = storage.value.currentAccessToken else {
                    let savedToken: String? = try keychain.get(.appAccessToken)
                    if let savedToken {
                        storage.withValue { $0.currentAccessToken = savedToken }
                    }
                    return savedToken
                }

                return token
            },
            currentUser: { storage.value.currentUser },
            currentUsers: {
                subject.values.eraseToStream()
            },
            logout: {
                storage.withValue {
                    $0.currentAccessToken = nil
                    $0.currentUser = nil
                }
                Task {
                    try? await facebook.signOut()
                    try? await google.signOut()
                    try? await supabase.signOut()
                }
                subject.send(nil)
                try keychain.delete(.appAccessToken)
            }
        )
    }
}
