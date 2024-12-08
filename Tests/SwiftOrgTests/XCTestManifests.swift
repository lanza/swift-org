extension TokenizerTests {
  nonisolated(unsafe) static var allTests = [
      ("testTokenBlank", testTokenBlank),
      ("testTokenSetting", testTokenSetting),
      ("testTokenHeading", testTokenHeading),
      ("testTokenPlanning", testTokenPlanning),
      ("testTokenBlockBegin", testTokenBlockBegin),
      ("testTokenBlockEnd", testTokenBlockEnd),
      ("testTokenComment", testTokenComment),
      ("testTokenHorizontalRule", testTokenHorizontalRule),
      ("testTokenListItem", testTokenListItem),
      ("testDrawer", testDrawer),
      ("testFootnote", testFootnote),
      ("testTable", testTable),
    ]
}

// extension LexerTests {
//     static var allTests = []
// }

extension ParserTests {
  nonisolated(unsafe) static var allTests = [
      ("testParseSettings", testParseSettings),
      ("testDefaultTodos", testDefaultTodos),
      ("testInBufferTodos", testInBufferTodos),
      ("testParseHeadline", testParseHeadline),
      ("testParseDrawer", testParseDrawer),
      ("testMalfunctionDrawer", testMalfunctionDrawer),
      ("testPriority", testPriority),
      ("testTags", testTags),
      ("testPlanning", testPlanning),
      ("testParseBlock", testParseBlock),
      ("testParseList", testParseList),
      ("testListItemWithCheckbox", testListItemWithCheckbox),
      ("testParseParagraph", testParseParagraph),
      ("testParseTable", testParseTable),
      ("testOnelineFootnote", testOnelineFootnote),
    ]
}

extension IndexingTests {
  nonisolated(unsafe) static var allTests = [
      ("testIndexing", testIndexing),
      ("testSectionIndexing", testSectionIndexing),
    ]
}

extension InlineParsingTests {
  nonisolated(unsafe) static var allTests = [
      ("testInlineParsing", testInlineParsing),
      ("testCornerCases", testCornerCases),
      ("testInlineFootnote", testInlineFootnote),
    ]
}

extension TimestampTests {
  nonisolated(unsafe) static var allTests = [
      ("testParseTimestamp", testParseTimestamp),
      ("testTimestampWithSpacing", testTimestampWithSpacing),
      ("testTimestampWithRepeater", testTimestampWithRepeater),
      ("testTimestampWithInvalidRepeater", testTimestampWithInvalidRepeater),
      ("testInvalidTimestamp", testInvalidTimestamp),
    ]
}

extension ConvertToJSONTests {
  nonisolated(unsafe) static var allTests = [
        ("testJSONConvertion", testJSONConvertion),
    ]
}
