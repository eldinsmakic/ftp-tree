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
            drwxr-xr-x   31 997      997          4096 Jan 31 20:47 cdimage\r\ndrwxr-xr-x   26 997      997          4096 Jan 31 21:14 cloud-images\r\ndrwxr-xr-x    8 997      997          4096 Jan 31 21:02 maas-images\r\ndrwxr-xr-x    5 997      997          4096 May 11  2010 old-images\r\n-rwxr-xr-x   13 997      997          4096 Jan 31 19:24 releases\r\n
            """

        XCTAssertEqual(listResultFormatter.mapMessageToTree(message: message), [
                        ["d","cdimage"],
                        ["d","cloud-images"],
            ["d","maas-images"],
            ["d","old-images"],
            ["-","releases"]
        ])
    }
}
