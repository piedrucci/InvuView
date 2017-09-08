
import Foundation

class OrderListener {
    private var timer: Timer?
    
    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(handleMyFunction), userInfo: nil, repeats: true)
    }
    
    func stop() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
    }
    
    
    @objc func handleMyFunction() {
        print("update info...")
    }
}
