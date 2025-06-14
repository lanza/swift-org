//
//  OrgDocument.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 21/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct OrgDocument: Node {
  public var settings = [String: String]()
  public var content = [Node]()

  public var title: String? {
    return settings["TITLE"]
  }

  public let defaultTodos: [[String]]

  public var todos: [[String]] {
    if let todo = settings["TODO"] {
      let keywords = todo.components(separatedBy: .whitespaces)
      var result: [[String]] = [[]]
      for keyword in keywords {
        if keyword == "|" {
          result.append([])
        } else {
          result[result.endIndex - 1].append(keyword)
        }
      }
      return result
    }
    return defaultTodos
  }

  public init(todos: [[String]]) {
    defaultTodos = todos
  }

  public var description: String {
    return "OrgDocument(settings: \(settings))\n - \(content)"
  }

  // MARK: - Transformation Methods

  /// Find a section by its index path
  public func findSection(at index: OrgIndex) -> Section? {
    return findSectionRecursive(in: content, targetIndex: index)
  }

  private func findSectionRecursive(in nodes: [Node], targetIndex: OrgIndex)
    -> Section?
  {
    for node in nodes {
      if let section = node as? Section, section.index == targetIndex {
        return section
      }
      if let section = node as? Section {
        if let found = findSectionRecursive(
          in: section.content, targetIndex: targetIndex)
        {
          return found
        }
      }
    }
    return nil
  }

  /// Move content from one section to another
  public mutating func moveContent(
    from sourceIndex: OrgIndex, to targetIndex: OrgIndex, contentIndex: Int
  ) -> Bool {
    guard var sourceSection = findSection(at: sourceIndex),
      var targetSection = findSection(at: targetIndex),
      contentIndex < sourceSection.content.count
    else {
      return false
    }

    let contentToMove = sourceSection.content.remove(at: contentIndex)
    targetSection.content.append(contentToMove)

    // Update the document with modified sections
    updateSection(sourceSection)
    updateSection(targetSection)

    return true
  }

  /// Move a subsection (two asterisks) from one top-level section to another
  public mutating func moveSubsection(
    from sourceTopLevelIndex: Int, subsectionIndex: Int,
    to targetTopLevelIndex: Int
  ) -> Bool {
    guard sourceTopLevelIndex < content.count,
      targetTopLevelIndex < content.count,
      var sourceSection = content[sourceTopLevelIndex] as? Section,
      var targetSection = content[targetTopLevelIndex] as? Section,
      subsectionIndex < sourceSection.content.count,
      let subsectionToMove = sourceSection.content[subsectionIndex] as? Section,
      subsectionToMove.stars == 2
    else {
      return false
    }

    // Remove subsection from source
    sourceSection.content.remove(at: subsectionIndex)

    // Add subsection to target
    targetSection.content.append(subsectionToMove)

    // Update the document
    content[sourceTopLevelIndex] = sourceSection
    content[targetTopLevelIndex] = targetSection

    return true
  }

  /// Find all top-level sections (one asterisk)
  public var topLevelSections: [Section] {
    return content.compactMap { node in
      if let section = node as? Section, section.stars == 1 {
        return section
      }
      return nil
    }
  }

  /// Find subsections (two asterisks) within a top-level section
  public func subsections(in topLevelIndex: Int) -> [Section] {
    guard topLevelIndex < content.count,
      let section = content[topLevelIndex] as? Section
    else {
      return []
    }

    return section.content.compactMap { node in
      if let subsection = node as? Section, subsection.stars == 2 {
        return subsection
      }
      return nil
    }
  }

  /// Move a subsection by title from one section to another
  public mutating func moveSubsection(
    withTitle title: String, from sourceTopLevelIndex: Int,
    to targetTopLevelIndex: Int
  ) -> Bool {
    guard sourceTopLevelIndex < content.count,
      targetTopLevelIndex < content.count,
      var sourceSection = content[sourceTopLevelIndex] as? Section,
      var targetSection = content[targetTopLevelIndex] as? Section
    else {
      return false
    }

    // Find the subsection with the given title
    guard
      let subsectionIndex = sourceSection.content.firstIndex(where: { node in
        if let section = node as? Section, section.stars == 2,
          section.title == title
        {
          return true
        }
        return false
      })
    else {
      return false
    }

    return moveSubsection(
      from: sourceTopLevelIndex, subsectionIndex: subsectionIndex,
      to: targetTopLevelIndex)
  }

  private mutating func updateSection(_ updatedSection: Section) {
    var localContent = content
    updateSectionRecursive(in: &localContent, section: updatedSection)
    content = localContent
  }

  private mutating func updateSectionRecursive(
    in nodes: inout [Node], section: Section
  ) {
    for i in 0..<nodes.count {
      if let existingSection = nodes[i] as? Section,
        existingSection.index == section.index
      {
        nodes[i] = section
        return
      }
      if var existingSection = nodes[i] as? Section {
        updateSectionRecursive(in: &existingSection.content, section: section)
        nodes[i] = existingSection
      }
    }
  }
}

extension OrgParser {
  func parseDocument() throws -> OrgDocument {
    var index = OrgIndex([0])
    while let (_, token) = tokens.peek() {
      switch token {
      case let .setting(key, value):
        _ = tokens.dequeue()
        document.settings[key] = value
      default:
        if let node = try parseSection(index) {
          document.content.append(node)
          index = index.next
        }
      }
    }
    return document
  }
}
