//
//  Section.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 21/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Section: Node {

  // MARK: properties
  public var index: OrgIndex?

  public var title: String?
  public var stars: Int
  public var keyword: String?
  public var priority: Priority?
  public var tags: [String]?
  public var content = [Node]()

  public var drawers: [Drawer]? {
    let ds = content.filter { node in
      return node is Drawer
    }.map { node in
      return node as! Drawer
    }
    return ds
  }

  public var planning: Planning? {
    return content.first { $0 is Planning } as? Planning
  }

  // MARK: func
  public init(stars l: Int, title t: String?, todos: [String]) {
    stars = l
    // TODO limit charset on tags
    let pattern =
      "^(?:(\(todos.joined(separator: "|")))\\s+)?(?:\\[#([ABCabc])\\]\\s+)?(.*?)(?:\\s+((?:\\:.+)+\\:)\\s*)?$"
    if let text = t, let m = text.match(pattern) {
      keyword = m[1]
      if let p = m[2] {
        priority = Priority(rawValue: p.uppercased())
      }
      title = m[3]
      if let t = m[4] {
        tags = t.components(separatedBy: ":").filter({ !$0.isEmpty })
      }
    } else {
      title = t
    }
  }

  public var description: String {
    return
      "Section[\(String(describing: index))](stars: \(stars), keyword: \(String(describing: keyword))), priority: \(String(describing: priority))), title: \(String(describing: title))\n - tags: \(String(describing: tags))\n - \(String(describing: drawers))\n - \(content)"
  }
  
  // MARK: - Transformation Methods
  
  /// Add content to this section
  public mutating func addContent(_ node: Node) {
    content.append(node)
  }
  
  /// Remove content at specified index
  public mutating func removeContent(at index: Int) -> Node? {
    guard index < content.count else { return nil }
    return content.remove(at: index)
  }
  
  /// Insert content at specified index
  public mutating func insertContent(_ node: Node, at index: Int) {
    guard index <= content.count else { return }
    content.insert(node, at: index)
  }
  
  /// Find all lists in this section
  public var lists: [List] {
    return content.compactMap { $0 as? List }
  }
  
  /// Find list at specified index in content
  public func findList(at contentIndex: Int) -> List? {
    guard contentIndex < content.count else { return nil }
    return content[contentIndex] as? List
  }
  
  /// Find all subsections (sections with more stars than this section)
  public var subsections: [Section] {
    return content.compactMap { node in
      if let section = node as? Section, section.stars > self.stars {
        return section
      }
      return nil
    }
  }
  
  /// Find subsection by title
  public func findSubsection(withTitle title: String) -> Section? {
    return content.first { node in
      if let section = node as? Section, section.stars > self.stars, section.title == title {
        return true
      }
      return false
    } as? Section
  }
  
  /// Remove subsection by title
  public mutating func removeSubsection(withTitle title: String) -> Section? {
    guard let index = content.firstIndex(where: { node in
      if let section = node as? Section, section.stars > self.stars, section.title == title {
        return true
      }
      return false
    }) else {
      return nil
    }
    
    return content.remove(at: index) as? Section
  }
  
  /// Add a subsection to this section
  public mutating func addSubsection(_ subsection: Section) {
    content.append(subsection)
  }
}

public struct Planning: Node {
  public let keyword: PlanningKeyword
  public let timestamp: Timestamp?

  public var description: String {
    return
      "Planning(keyword: \(keyword), timestamp: \(String(describing: timestamp)))"
  }
}

extension OrgParser {
  func parseSection(_ index: OrgIndex) throws -> Node? {
    skipBlanks()  // in a section, you don't care about blanks

    guard let (_, token) = tokens.peek() else {
      return nil
    }
    switch token {
    case let .headline(l, t):
      if l < index.indexes.count {
        return nil
      }
      _ = tokens.dequeue()
      var section = Section(
        stars: l, title: t, todos: document.todos.flatMap { $0 })
      section.index = index
      var subIndex = index.in
      while let subSection = try parseSection(subIndex) {
        section.content.append(subSection)
        subIndex = subIndex.next
      }
      return section
    case .footnote:
      return try parseFootnote()
    default:
      return try parseTheRest()
    }
  }
}
