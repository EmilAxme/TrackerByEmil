//
//  ScreenShotTests.swift
//  ScreenShotTests
//
//  Created by Emil on 19.09.2025.
//

import XCTest
import SnapshotTesting
@testable import TrackerByEmil

final class ScreenShotTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testViewController() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()! // 1
        
        assertSnapshot(of: vc, as: .image)                                    // 2
    }

    func testViewControllerDarkMode() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        
        assertSnapshot(
            of: vc,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            named: "dark"
        )
    }
    
}

