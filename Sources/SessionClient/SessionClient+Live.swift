@preconcurrency import Combine
import Dependencies
import KeychainClient
import SharedModels

extension SessionClient: DependencyKey {
    public static var liveValue: SessionClient {
        struct Storage {
            var currentUser: User?
            var currentAuthenticationToken: String?
        }

        let storage = LockIsolated(Storage())
        let subject = PassthroughSubject<User?, Never>()

        @Dependency(\.keychain) var keychain

        return Self(
            authenticate: { user in
                storage.withValue { $0.currentUser = user }
                subject.send(user)
            },
            setCurrentAuthenticationToken: { token in
                storage.withValue { $0.currentAuthenticationToken = token }
                try keychain.set(.appAuthenticationToken, to: token)
            },
            currentAuthenticationToken: {
                guard let token = storage.value.currentAuthenticationToken else {
                    let savedToken: String? = try keychain.get(.appAuthenticationToken)
                    if let savedToken {
                        storage.withValue { $0.currentAuthenticationToken = savedToken }
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
                    $0.currentAuthenticationToken = nil
                    $0.currentUser = nil
                }
                subject.send(nil)
                try keychain.delete(.appAuthenticationToken)
            }
        )
    }
}
