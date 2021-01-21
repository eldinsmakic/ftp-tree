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
        let listResultFormatter = ListResultFormatter()

        XCTAssertEqual(listResultFormatter.trimMessage(message: "pub\r\n04-08-14"), "pub")

        XCTAssertEqual(listResultFormatter.trimMessage(message: "readme.txt\r\n"), "readme.txt")
    }

    func testMapToTree() {
        let listResultFormatter = ListResultFormatter()
        let message = """
              10-19-20  03:19PM       <DIR>          pub\r\n04-08-14  03:09PM                  403 readme.txt\r\n
        """

        XCTAssertEqual(listResultFormatter.mapMessageToTree(message: message ), [["<DIR>","pub"],["403","readme.txt"]])
    }
}
