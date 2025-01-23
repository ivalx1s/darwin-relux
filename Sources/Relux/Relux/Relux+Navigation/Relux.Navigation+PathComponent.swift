public extension Relux.Navigation {
	protocol PathComponent: Hashable {}
}


public extension Relux.Navigation {
    protocol ModalComponent: PathComponent, Identifiable {}
}

public extension Relux.Navigation.ModalComponent {
    var id: Int {
        self.hashValue
    }
}
