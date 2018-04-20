//
//  Account+CoreDataProperties.swift
//  Balancing Act
//
//  Created by Drew Lanning on 4/19/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var name: String?
    @NSManaged public var bank: String?
    @NSManaged public var accountNumber: Int64
    @NSManaged public var startingBalance: Double
    @NSManaged public var currentBalance: Double
    @NSManaged public var creation: NSDate?
    @NSManaged public var lastReconcile: NSDate?
    @NSManaged public var transactions: NSSet?

}

// MARK: Generated accessors for transactions
extension Account {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}
