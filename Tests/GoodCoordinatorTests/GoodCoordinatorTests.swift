//
//  GoodCoordinatorTests.swift
//  GoodReactor
//
//  Created by Matúš Mištrik on 20/01/2025.
//

import LegacyReactor
import XCTest

final class GoodCoordinatorTests: XCTestCase {

    @MainActor func testCoordinatorTypeCasting() {
        let firstCoordinator = CoordinatorA() // uses CustomStepA
        let secondCoordinator = CoordinatorB(parentCoordinator: firstCoordinator)

        let secondCoordinatorParentAsBaseOfRandom = secondCoordinator.parentCoordinator as? GoodCoordinator<CustomStepC>
        let secondCoordinatorParentAsBaseOfFirst = secondCoordinator.parentCoordinator as? GoodCoordinator<CustomStepA>
        let secondCoordinatorParentAsFirst = secondCoordinator.parentCoordinator as? CoordinatorA

        XCTAssertNil(firstCoordinator.parentCoordinator)
        XCTAssertNil(secondCoordinatorParentAsBaseOfRandom)

        XCTAssertNotNil(secondCoordinatorParentAsBaseOfFirst)
        XCTAssertNotNil(secondCoordinatorParentAsFirst)
    }

    @MainActor func testCoordinatorSearchBasedOnType() {
        let firstCoordinator = CoordinatorA()
        let secondCoordinator = CoordinatorB(parentCoordinator: firstCoordinator)
        let thirdCoordinator = CoordinatorA(parentCoordinator: secondCoordinator)
        let fourthCoordinator  = CoordinatorC(parentCoordinator: thirdCoordinator)

        let firstCoordinatorOfTypeA = fourthCoordinator.firstCoordinatorOfType(type: CoordinatorA.self)
        XCTAssertNotNil(firstCoordinatorOfTypeA)
        XCTAssertNotNil(firstCoordinatorOfTypeA?.parentCoordinator)

        let lastCoordinatorOfTypeA = fourthCoordinator.lastCoordinatorOfType(type: CoordinatorA.self)
        XCTAssertNotNil(lastCoordinatorOfTypeA)
        XCTAssertNil(lastCoordinatorOfTypeA?.parentCoordinator)
    }

    @MainActor func testCoordinatorSearchBasedOnItsChildren() {
        let firstCoordinator = CoordinatorA()
        let secondCoordinator = CoordinatorC(parentCoordinator: firstCoordinator)
        secondCoordinator.id = 1
        let thirdCoordinator = CoordinatorB(parentCoordinator: firstCoordinator)
        let fourthCoordinator  = CoordinatorC(parentCoordinator: firstCoordinator)
        fourthCoordinator.id = 2
        let fifthCoordinator = CoordinatorB(parentCoordinator: firstCoordinator)

        let lastCoordinatorOfTypeC = firstCoordinator.lastChildOfType(type: CoordinatorC.self)
        XCTAssertNotNil(lastCoordinatorOfTypeC)
        XCTAssertTrue(lastCoordinatorOfTypeC?.id == 2)

        let lastChild = firstCoordinator.lastChild()
        XCTAssertNotNil(lastChild)

        let lastChildCastedToTypeB = lastChild as? CoordinatorB
        XCTAssertNotNil(lastChildCastedToTypeB)

        let lastChildCastedToTypeC = lastChild as? CoordinatorC
        XCTAssertNil(lastChildCastedToTypeC)

        firstCoordinator.resetChildReferences()
    }

    @MainActor func testCoordinatorInitializers() {
        let navigationController = UINavigationController()
        let firstCoordinator = CoordinatorA(rootViewController: navigationController)
        let secondCoordinator = CoordinatorB(parentCoordinator: firstCoordinator)
        let thirdCoordinator = CoordinatorB(rootViewController: nil, parentCoordinator: firstCoordinator)


        XCTAssertNotNil(secondCoordinator.rootViewController)
        XCTAssertNil(thirdCoordinator.rootViewController)
    }

}
