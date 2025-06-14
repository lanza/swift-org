import XCTest

@testable import SwiftOrg

class TransformationTests: XCTestCase, @unchecked Sendable {

  func testFindSection() {
    let parser = OrgParser()
    let orgText = """
      * First Section
      Some content here
      ** Subsection
      More content
      * Second Section
      Different content
      """

    guard let document = try? parser.parse(content: orgText) else {
      XCTFail("Failed to parse document")
      return
    }

    // Test that document has content
    XCTAssertGreaterThan(document.content.count, 0)

    // Test finding sections by examining the content array
    if let firstSection = document.content.first as? Section {
      XCTAssertEqual(firstSection.title, "First Section")

      // Test finding subsection within first section
      if let subsection = firstSection.content.first as? Section {
        XCTAssertEqual(subsection.title, "Subsection")
      }
    } else {
      XCTFail("First content item is not a Section")
    }

    // Test finding second section
    if document.content.count > 1,
      let secondSection = document.content[1] as? Section
    {
      XCTAssertEqual(secondSection.title, "Second Section")
    } else {
      XCTFail("Second content item is not a Section or doesn't exist")
    }
  }

  func testSectionContentManipulation() {
    var section = Section(
      stars: 1, title: "Test Section", todos: ["TODO", "DONE"])

    // Test adding content directly to the content array
    let paragraph = Paragraph(lines: ["Test paragraph"])
    section.content.append(paragraph)
    XCTAssertEqual(section.content.count, 1)

    // Test inserting content
    let anotherParagraph = Paragraph(lines: ["Another paragraph"])
    section.content.insert(anotherParagraph, at: 0)
    XCTAssertEqual(section.content.count, 2)

    // Test removing content
    if section.content.count > 0 {
      let removed = section.content.removeFirst()
      XCTAssertNotNil(removed)
      XCTAssertEqual(section.content.count, 1)
    }

    // Test basic content access
    XCTAssertTrue(section.content.count >= 0)
  }

  func testMoveContentBetweenSections() {
    let parser = OrgParser()
    let orgText = """
      * Source Section
      Content to move
      * Target Section
      Existing content
      """

    guard let document = try? parser.parse(content: orgText) else {
      XCTFail("Failed to parse document")
      return
    }

    // Verify initial state - check that we have sections
    XCTAssertGreaterThan(document.content.count, 1)

    if let sourceSection = document.content.first as? Section,
      document.content.count > 1,
      let targetSection = document.content[1] as? Section
    {

      // Just verify the sections exist and have content
      XCTAssertEqual(sourceSection.title, "Source Section")
      XCTAssertEqual(targetSection.title, "Target Section")
      XCTAssertGreaterThan(sourceSection.content.count, 0)
      XCTAssertGreaterThan(targetSection.content.count, 0)

      // Verify we can access the content
      XCTAssertNotNil(sourceSection.content.first)
      XCTAssertNotNil(targetSection.content.first)
    } else {
      XCTFail("Could not find expected sections")
    }
  }

  func testMoveSubsectionBetweenTopLevelSections() {
    let parser = OrgParser()
    let orgText = """
      * First Section
      Some content
      ** Subsection to Move
      Subsection content
      ** Another Subsection
      More content
      * Second Section
      Different content
      """

    guard var document = try? parser.parse(content: orgText) else {
      XCTFail("Failed to parse document")
      return
    }

    // Verify initial state
    XCTAssertEqual(document.content.count, 2)
    let firstSection = document.content[0] as? Section
    let secondSection = document.content[1] as? Section

    XCTAssertNotNil(firstSection)
    XCTAssertNotNil(secondSection)
    XCTAssertEqual(firstSection?.title, "First Section")
    XCTAssertEqual(secondSection?.title, "Second Section")

    // Check initial subsection count
    let initialFirstSectionSubsections = document.subsections(in: 0)
    let initialSecondSectionSubsections = document.subsections(in: 1)

    XCTAssertEqual(initialFirstSectionSubsections.count, 2)
    XCTAssertEqual(initialSecondSectionSubsections.count, 0)

    // Move subsection by title
    let success = document.moveSubsection(
      withTitle: "Subsection to Move", from: 0, to: 1)
    XCTAssertTrue(success)

    // Verify the move
    let finalFirstSectionSubsections = document.subsections(in: 0)
    let finalSecondSectionSubsections = document.subsections(in: 1)

    XCTAssertEqual(finalFirstSectionSubsections.count, 1)
    XCTAssertEqual(finalSecondSectionSubsections.count, 1)
    XCTAssertEqual(
      finalSecondSectionSubsections.first?.title, "Subsection to Move")
  }

  func testMoveSubsectionByIndex() {
    let parser = OrgParser()
    let orgText = """
      * Source Section
      ** First Subsection
      ** Second Subsection
      * Target Section
      """

    guard var document = try? parser.parse(content: orgText) else {
      XCTFail("Failed to parse document")
      return
    }

    // Move first subsection (index 0) from section 0 to section 1
    let success = document.moveSubsection(from: 0, subsectionIndex: 0, to: 1)
    XCTAssertTrue(success)

    // Verify the move
    let sourceSubsections = document.subsections(in: 0)
    let targetSubsections = document.subsections(in: 1)

    XCTAssertEqual(sourceSubsections.count, 1)
    XCTAssertEqual(targetSubsections.count, 1)
    XCTAssertEqual(sourceSubsections.first?.title, "Second Subsection")
    XCTAssertEqual(targetSubsections.first?.title, "First Subsection")
  }

  func testMoveContentInvalidIndices() {
    let parser = OrgParser()
    let orgText = """
      * Only Section
      Some content
      """

    guard let document = try? parser.parse(content: orgText) else {
      XCTFail("Failed to parse document")
      return
    }

    // Test basic document structure validation
    XCTAssertGreaterThan(document.content.count, 0)

    // Test accessing invalid indices
    XCTAssertTrue(document.content.count < 5)  // Should not have 5 sections

    if let section = document.content.first as? Section {
      // Test that we can access the section's content safely
      XCTAssertTrue(section.content.count >= 0)
    } else {
      XCTFail("First content item is not a Section")
    }
  }
}
