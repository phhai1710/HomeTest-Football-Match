//
//  ReachabilityService.swift
//  FootballMatches
//
//  Created by Hai Pham on 28/02/2023.
//

import Combine
import Network

enum NerworkType {
    case wifi
    case cellular
    case loopBack
    case wired
    case other
}

protocol ReachabilityServiceContract {
    var reachabilityInfos: PassthroughSubject<NWPath, Never> { get set }
    var isNetworkAvailable: CurrentValueSubject<Bool, Never> { get set }
    var typeOfCurrentConnection: PassthroughSubject<NerworkType, Never> { get set }
}

final class ReachabilityService: ReachabilityServiceContract {
    static let shared = ReachabilityService()
    
    var reachabilityInfos: PassthroughSubject<NWPath, Never> = .init()
    var isNetworkAvailable: CurrentValueSubject<Bool, Never> = .init(false)
    var typeOfCurrentConnection: PassthroughSubject<NerworkType, Never> = .init()

    private let monitor: NWPathMonitor
    private let backgroudQueue = DispatchQueue.global(qos: .background)

    init() {
        monitor = NWPathMonitor()
        setUp()
    }

    init(with interFaceType: NWInterface.InterfaceType) {
        monitor = NWPathMonitor(requiredInterfaceType: interFaceType)
        setUp()
    }

    deinit {
        monitor.cancel()
    }
}

private extension ReachabilityService {
    func setUp() {
    
        monitor.pathUpdateHandler = { [weak self] path in
            self?.reachabilityInfos.send(path)
            switch path.status {
            case .satisfied:
                self?.isNetworkAvailable.send(true)
            case .unsatisfied, .requiresConnection:
                self?.isNetworkAvailable.send(false)
            @unknown default:
                self?.isNetworkAvailable.send(false)
            }
            if path.usesInterfaceType(.wifi) {
                self?.typeOfCurrentConnection.send(.wifi)
            } else if path.usesInterfaceType(.cellular) {
                self?.typeOfCurrentConnection.send(.cellular)
            } else if path.usesInterfaceType(.loopback) {
                self?.typeOfCurrentConnection.send(.loopBack)
            } else if path.usesInterfaceType(.wiredEthernet) {
                self?.typeOfCurrentConnection.send(.wired)
            } else if path.usesInterfaceType(.other) {
                self?.typeOfCurrentConnection.send(.other)
            }
        }
    
        monitor.start(queue: backgroudQueue)
    }
}
