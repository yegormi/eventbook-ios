@preconcurrency import Combine
import Dependencies
import FacebookClient
import GoogleClient
import KeychainClient
import SharedModels

extension SessionClient: DependencyKey {
    public static var liveValue: SessionClient {
        struct Storage {
            var currentUser: User?
            var currentIDToken: String?
            var currentAccessToken: String?
        }

        let storage = LockIsolated(Storage())
        let subject = PassthroughSubject<User?, Never>()

        @Dependency(\.keychain) var keychain

        @Dependency(\.authGoogle) var google

        @Dependency(\.authFacebook) var facebook

        return Self(
            authenticate: { user in
                storage.withValue { $0.currentUser = user }
                subject.send(user)
            },
            setCurrentAccessToken: { token in
                storage.withValue { $0.currentAccessToken = token }
                try keychain.set(.appAccessToken, to: token)
            },
            setCurrentIDToken: { token in
                storage.withValue { $0.currentIDToken = token }
                try keychain.set(.appIDToken, to: token)
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
            currentIDToken: {
                guard let token = storage.value.currentIDToken else {
                    let savedToken: String? = try keychain.get(.appIDToken)
                    if let savedToken {
                        storage.withValue { $0.currentIDToken = savedToken }
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
                    $0.currentIDToken = nil
                    $0.currentAccessToken = nil
                    $0.currentUser = nil
                }
                Task {
                    try? await facebook.signOut()
                    try? await google.signOut()
                }
                subject.send(nil)
                try keychain.delete(.appIDToken)
                try keychain.delete(.appAccessToken)
            }
        )
    }
}
