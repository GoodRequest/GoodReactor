//
//  AnyTask.swift
//  GoodReactor
//
//  Created by Filip Šašala on 28/08/2024.
//

import Foundation

public final class AnyTask: Identifiable {

    /// Cancel the task manually.
    let cancel: () -> Void

    /// Checks whether the task is cancelled.
    var isCancelled: Bool { isCancelledBlock() }

    private let isCancelledBlock: () -> Bool

    deinit {
        if !isCancelled { cancel() }
    }

    init<S, E>(_ task: Task<S, E>) {
        cancel = task.cancel
        isCancelledBlock = { task.isCancelled }
    }
}

extension AnyTask: Hashable, Equatable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public static func == (lhs: AnyTask, rhs: AnyTask) -> Bool {
        return lhs.id == rhs.id
    }

}

public extension Task {

    var eraseToAnyTask: AnyTask { AnyTask(self) }

    func store(in collection: inout some RangeReplaceableCollection<AnyTask>) {
        collection.append(eraseToAnyTask)
    }

    func store(in set: inout some SetAlgebra<AnyTask>) {
        set.insert(eraseToAnyTask)
    }

}
