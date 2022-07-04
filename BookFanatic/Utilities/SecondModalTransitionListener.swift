import Foundation

protocol SecondaryModalTransitionListener {
    func popoverDismissed()
}

class SecondaryModalTransitionMediator {
    
    /* Singleton */
    class var instance: SecondaryModalTransitionMediator {
        struct Static {
            static let instance: SecondaryModalTransitionMediator = SecondaryModalTransitionMediator()
        }
        return Static.instance
    }
    
    private var listener: SecondaryModalTransitionListener?
    
    private init() {
        
    }
    
    func setListener(listener: SecondaryModalTransitionListener) {
        self.listener = listener
    }
    
    func sendPopoverDismissed(modelChanged: Bool) {
        listener?.popoverDismissed()
    }
}
