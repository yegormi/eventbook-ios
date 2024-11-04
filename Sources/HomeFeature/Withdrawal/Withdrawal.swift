import APIClientLive
import ComposableArchitecture
import Foundation
import SharedModels

@Reducer
public struct Withdrawal: Reducer {
    @ObservableState
    public struct State: Equatable {
        public enum Field: Hashable {
            case amount
        }
        
        var balance: AppBalance
        var amount: Decimal?
        var focus: Field? = .amount
        var isExceededBalance: Bool {
            guard let amount = self.amount else { return false }
            return amount > self.balance.balance
        }
        var isFormValid: Bool {
            guard let amount = self.amount else { return false }
            return amount > 0 && !self.isExceededBalance
        }
    }

    public enum Action: ViewAction {
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
        case `internal`(Internal)
        case view(View)

        public enum Delegate {
            case withdrawalDone
        }

        public enum Internal {
        }

        public enum View: BindableAction {
            case binding(BindingAction<Withdrawal.State>)
            case continueButtonTapped
            case onFirstAppear
            case onAppear
        }
    }

    @Reducer(state: .equatable)
    public enum Destination {}

    @Dependency(\.apiClient) var api

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .delegate:
                return .none

            case .destination:
                return .none

            case .internal:
                return .none

            case .view(.binding):
                return .none

            case .view(.onFirstAppear):
                return .none

            case .view(.onAppear):
                return .none
                
            case .view(.continueButtonTapped):
                return .send(.delegate(.withdrawalDone))
            }
        }
    }
}
