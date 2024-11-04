import TabsFeature
import ComposableArchitecture
import Dependencies
import OSLog

private let logger = Logger(subsystem: "AppFeature", category: "AppReducer")

@Reducer
public struct AppReducer: Reducer {
    @ObservableState
    public struct State: Equatable {
        var destination = Destination.State.loading
        
        public init() {}
    }
    
    public enum Action {
        case destination(Destination.Action)
        case changeToDestination(Destination.State)
        case task
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        @ReducerCaseIgnored
        case loading
        case tabs(Tabs)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.destination, action: \.destination) {
            Destination.body
        }
        
        Reduce { state, action in
            switch action {
                
            case .destination:
                return .none
                
            case .changeToDestination(let destination):
                state.destination = destination
                return .none
                
            case .task:
                return .run { send in
                    await send(.changeToDestination(.tabs(Tabs.State())))
                    logger.info("Showing main screen.")
                }
            }
        }
    }
}
