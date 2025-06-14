//
//  OrgFileWriterTests.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 29/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import SwiftOrg
import XCTest

class OrgFileWriterTests: XCTestCase {

  func testOrgFileWriter() throws {
    // Use the README.org content directly instead of trying to load from bundle
    let content = """
      #+TITLE: SwiftOrg

      * org-mode Parser for Swift

        [[https://travis-ci.org/xiaoxinghu/swift-org.svg?branch=master]]
        [[https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000]]
        [[https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat]]
        [[https://img.shields.io/github/release/xiaoxinghu/swift-org.svg?maxAge=2592000]]

        [[http://orgmode.org/][org-mode]] is awesome. This is the first step to bring it to iOS, (arguably) the
        most popular platform on the planet.

      * Usage
        An simple example will explain everything.

        #+BEGIN_SRC swift
          import SwiftOrg

          let lines = [
              "* TODO head line",
              "  A normal line here.",
          ]
          let parser = OrgParser()
          let doc = try parser.parse(lines: lines)
        #+END_SRC
      """

    let parser = OrgParser()
    let doc = try parser.parse(content: content)

    let text = doc.toText()
    XCTAssertFalse(text.isEmpty)
    // Verify basic structure is preserved
    XCTAssertTrue(text.contains("#+TITLE: SwiftOrg"))
    XCTAssertTrue(text.contains("* org-mode Parser for Swift"))
    XCTAssertTrue(text.contains("* Usage"))
  }

}
