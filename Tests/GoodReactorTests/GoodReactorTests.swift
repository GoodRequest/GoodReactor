import XCTest
import GoodReactor
import UIKit

final class GoodCoordinatorTests: XCTestCase {

    func testGoodCoordinatorParent() {
        let firstCoordinator = FirstCoordinator(parentCoordinator: nil)
        let secondCoordinator = SecondCoordinator(parentCoordinator: firstCoordinator)
        let thirdCoordinator = ThirdCoordinator(parentCoordinator: secondCoordinator)
        let fourthCoordinator = FourthCoordinator(parentCoordinator: thirdCoordinator)

        XCTAssert(fourthCoordinator.firstCoordinatorOfType(type: ThirdCoordinator.self) == thirdCoordinator)
        XCTAssert(fourthCoordinator.firstCoordinatorOfType(type: SecondCoordinator.self) == secondCoordinator)
        XCTAssert(fourthCoordinator.lastCoordinatorOfType(type: FirstCoordinator.self) == firstCoordinator)
    }

    func testFirstCoordinatorParent() {
        // When
        let firstCoordinator = FirstCoordinator()
        let secondCoordinator = SecondCoordinator(parentCoordinator: firstCoordinator)
        let thirdCoordinator = ThirdCoordinator(parentCoordinator: secondCoordinator)
        let secondSecondCoordinator = SecondCoordinator(parentCoordinator: thirdCoordinator)
        let lastCoordinator = FourthCoordinator(parentCoordinator: secondSecondCoordinator)

        // Then
        XCTAssert(lastCoordinator.firstCoordinatorOfType(type: FirstCoordinator.self) === firstCoordinator)
        XCTAssert(lastCoordinator.firstCoordinatorOfType(type: SecondCoordinator.self) === secondSecondCoordinator)
        XCTAssert(lastCoordinator.firstCoordinatorOfType(type: FourthCoordinator.self) === lastCoordinator)
        XCTAssertFalse(lastCoordinator.firstCoordinatorOfType(type: SecondCoordinator.self) === secondCoordinator)
    }

    func testLastCoordinatorParent() {
        // When
        let firstCoordinator = FirstCoordinator()
        let secondCoordinator = SecondCoordinator(parentCoordinator: firstCoordinator)
        let thirdCoordinator = ThirdCoordinator(parentCoordinator: secondCoordinator)
        let secondSecondCoordinator = SecondCoordinator(parentCoordinator: thirdCoordinator)
        let lastCoordinator = FourthCoordinator(parentCoordinator: secondSecondCoordinator)

        // Then
        XCTAssert(lastCoordinator.lastCoordinatorOfType(type: FourthCoordinator.self) === lastCoordinator)
        XCTAssert(lastCoordinator.lastCoordinatorOfType(type: SecondCoordinator.self) === secondCoordinator)
        XCTAssert(lastCoordinator.lastCoordinatorOfType(type: FirstCoordinator.self) === firstCoordinator)
        XCTAssertFalse(lastCoordinator.lastCoordinatorOfType(type: SecondCoordinator.self) === secondSecondCoordinator)
    }

}

enum Steps {

    case firstStep

}

class FirstCoordinator: GoodCoordinator<Steps> {}
class SecondCoordinator: GoodCoordinator<Steps> {}
class ThirdCoordinator: GoodCoordinator<Steps> {}
class FourthCoordinator: GoodCoordinator<Steps> {}
