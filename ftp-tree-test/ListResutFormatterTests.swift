//
//  ListResutFormatterTest.swift
//  ftp-tree-test
//
//  Created by eldin smakic on 20/01/2021.
//

import XCTest
@testable import ftp_tree

class ListResutFormatterTest: XCTestCase {

    func testTrim() {
        let message = "pub\r\n04-08-14"
        let listResultFormatter = ListResultFormatter()
        XCTAssertEqual(listResultFormatter.trimMessage(message: message), "pub")
    }

}
