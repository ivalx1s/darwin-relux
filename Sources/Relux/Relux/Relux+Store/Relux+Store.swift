extension Relux {
	public actor Store: Relux.Subscriber, Sendable {
		
		@MainActor
		public private(set) var uistates: [ObjectIdentifier: any Relux.Presentation.StatePresenting] = [:]
		
		@MainActor
		public private(set) var routers: [ObjectIdentifier: any Relux.Navigation.RouterProtocol] = [:]
		
		@MainActor
		public private(set) var states: [ObjectIdentifier: any Relux.State] = [:]
		
		@MainActor
		internal private(set) var tempStates: [ObjectIdentifier: TemporalStateRef] = [:]
		
		public init() {
			Relux.Dispatcher.subscribe(self)
		}
		
		public func cleanup() async {
			await states
				.concurrentForEach { await $0.value.cleanup() }
		}
		
		@MainActor
		public func connectRouter(router: any Relux.Navigation.RouterProtocol) {
			routers[router.key] = router
		}
		
		@MainActor
		public func connectState(state: any Relux.State) {
			states[state.key] = state
		}
		
		@MainActor
		public func connectState(uistate: any Relux.Presentation.StatePresenting) {
			uistates[uistate.key] = uistate
		}
		
//		@MainActor
//		public func connectState(tempState: some Relux.TemporalState) -> some Relux.TemporalState {
//			tempStates[tempState.key] = .init(objectRef: tempState)
//			return tempState
//		}

        @MainActor
        public func connectState<TS: Relux.TemporalState>(tempState: TS) -> TS {
            tempStates[tempState.key] = .init(objectRef: tempState)
            return tempState
        }

		public func notify(_ action: Relux.Action) async {
			await states
				.concurrentForEach { pair in
					await pair.value.reduce(with: action)
				}
			
			await tempStates
				.concurrentForEach { pair in
					await pair.value.objectRef?.reduce(with: action)
				}
			
			await routers
				.concurrentForEach { pair in
					await pair.value.reduce(with: action)
				}
		}
		
		@MainActor
		@available(*, deprecated, message: "Use Relux modules")
		public func getState<T: Relux.State>(_ type: T.Type) -> T {
			let state = states[T.key]
			return state as! T
		}
		
		
		@MainActor
		@available(*, deprecated, message: "Use Relux modules")
		public func getState<T: Relux.Presentation.StatePresenting>(_ type: T.Type) -> T {
			let state = uistates[T.key]
			return state as! T
		}
		
	}
}
