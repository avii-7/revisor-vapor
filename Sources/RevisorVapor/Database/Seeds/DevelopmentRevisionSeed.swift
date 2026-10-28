import Fluent
import SQLKit
import Vapor

struct DevelopmentRevisionSeed {
    // Keep the marker even when samples are edited or deleted, so they stay deleted.
    static let tagTitle = "Development samples"

    func prepare(for userID: UUID, on database: any Database) async throws {
        try await database.transaction { db in
            guard let sql = db as? any SQLDatabase else {
                throw Abort(.internalServerError, reason: "Development seeding requires PostgreSQL")
            }

            // Serialize first requests for the same user, including across server processes.
            let user = try await sql.select().column("id").from(User.schema)
                .where("id", .equal, userID).for(.update).first()
            guard user != nil else { throw Abort(.unauthorized) }

            let marker = try await RevisionItemTag.query(on: db)
                .filter(\.$userId == userID)
                .filter(\.$title == Self.tagTitle)
                .first()
            guard marker == nil else { return }

            let tag = RevisionItemTag(userId: userID, title: Self.tagTitle)
            try await tag.create(on: db)
            let items = Self.items(for: userID, tagID: try tag.requireID())
            try await items.create(on: db)
        }
    }

    static func items(for userID: UUID, tagID: UUID, now: Date = .now) -> [RevisionItem] {
        examples.enumerated().map { index, example in
            let state: RevisionCardState = [.new, .learning, .review, .relearning][index % 4]
            let isNew = state == .new
            let dueOffset = index < 6 ? -Double(index + 1) * 3_600 : Double(index - 5) * TimeConstants.secondsPerDay
            return RevisionItem(
                userId: userID,
                title: example.title,
                content: example.content,
                platformUrl: "https://leetcode.com/problems/\(example.slug)/",
                keyIntuition: example.intuition,
                solutionCode: example.code,
                memoryState: MemoryState(
                    due: now.addingTimeInterval(dueOffset),
                    stability: isNew ? 0 : Double(index + 2),
                    difficulty: isNew ? 0 : 5,
                    reps: isNew ? 0 : index + 1,
                    lapses: state == .relearning ? 1 : 0,
                    state: state,
                    lastReview: isNew ? nil : now.addingTimeInterval(-2 * TimeConstants.secondsPerDay)
                ),
                tagIDs: [tagID]
            )
        }
    }

    private struct Example: Sendable {
        let title: String
        let slug: String
        let content: String
        let intuition: String
        let code: String
    }

    private static let examples: [Example] = [
        .init(title: "Two Sum", slug: "two-sum",
              content: "Return the indices of two numbers whose sum equals the target. Each input has exactly one solution.",
              intuition: "Store each visited number in a map. Check for its complement before inserting it. O(n) time and space.",
              code: "function twoSum(nums, target) {\n  const seen = new Map();\n  for (let i = 0; i < nums.length; i++) {\n    if (seen.has(target - nums[i])) return [seen.get(target - nums[i]), i];\n    seen.set(nums[i], i);\n  }\n}"),
        .init(title: "Valid Parentheses", slug: "valid-parentheses",
              content: "Determine whether brackets are closed in the correct order and with the matching type.",
              intuition: "Use a stack of opening brackets. Each closing bracket must match the most recent opening bracket.",
              code: "function isValid(s) {\n  const stack = [], pairs = { ')': '(', ']': '[', '}': '{' };\n  for (const ch of s) {\n    if ('([{'.includes(ch)) stack.push(ch);\n    else if (stack.pop() !== pairs[ch]) return false;\n  }\n  return stack.length === 0;\n}"),
        .init(title: "Best Time to Buy and Sell Stock", slug: "best-time-to-buy-and-sell-stock",
              content: "Find the maximum profit from buying once and selling on a later day. Return zero when no profit is possible.",
              intuition: "Track the lowest price so far and the best profit at each price. O(n) time, O(1) space.",
              code: "function maxProfit(prices) {\n  let low = Infinity, best = 0;\n  for (const price of prices) {\n    low = Math.min(low, price);\n    best = Math.max(best, price - low);\n  }\n  return best;\n}"),
        .init(title: "Binary Search", slug: "binary-search",
              content: "Find a target in an ascending sorted array, returning its index or -1.",
              intuition: "Discard half of the remaining range after comparing the middle element. Keep inclusive bounds consistent.",
              code: "function search(nums, target) {\n  let left = 0, right = nums.length - 1;\n  while (left <= right) {\n    const mid = left + Math.floor((right - left) / 2);\n    if (nums[mid] === target) return mid;\n    if (nums[mid] < target) left = mid + 1;\n    else right = mid - 1;\n  }\n  return -1;\n}"),
        .init(title: "Contains Duplicate", slug: "contains-duplicate",
              content: "Return true if any value appears at least twice in an integer array.",
              intuition: "A set removes duplicates. Compare its size with the input length.",
              code: "function containsDuplicate(nums) {\n  return new Set(nums).size !== nums.length;\n}"),
        .init(title: "Maximum Subarray", slug: "maximum-subarray",
              content: "Find the largest sum of a nonempty contiguous subarray.",
              intuition: "At each position, either extend the previous subarray or start a new one. Track the global maximum.",
              code: "function maxSubArray(nums) {\n  let current = nums[0], best = current;\n  for (let i = 1; i < nums.length; i++) {\n    current = Math.max(nums[i], current + nums[i]);\n    best = Math.max(best, current);\n  }\n  return best;\n}"),
        .init(title: "Climbing Stairs", slug: "climbing-stairs",
              content: "Count the ways to climb n stairs when each move advances one or two steps.",
              intuition: "Ways(n) = ways(n - 1) + ways(n - 2). Retain only the previous two values.",
              code: "function climbStairs(n) {\n  let previous = 1, current = 1;\n  for (let i = 2; i <= n; i++) [previous, current] = [current, previous + current];\n  return current;\n}"),
        .init(title: "Reverse Linked List", slug: "reverse-linked-list",
              content: "Reverse a singly linked list and return its new head.",
              intuition: "Save the next node before redirecting each link to the previous node.",
              code: "function reverseList(head) {\n  let previous = null;\n  while (head) {\n    const next = head.next;\n    head.next = previous;\n    previous = head;\n    head = next;\n  }\n  return previous;\n}"),
        .init(title: "Maximum Depth of Binary Tree", slug: "maximum-depth-of-binary-tree",
              content: "Return the number of nodes along the longest path from the root to a leaf.",
              intuition: "An empty subtree has depth zero. Otherwise add one to the greater child depth.",
              code: "function maxDepth(root) {\n  if (!root) return 0;\n  return 1 + Math.max(maxDepth(root.left), maxDepth(root.right));\n}"),
        .init(title: "Longest Substring Without Repeating Characters", slug: "longest-substring-without-repeating-characters",
              content: "Find the length of the longest substring containing no repeated characters.",
              intuition: "Maintain a sliding window and the last index of each character. Never move the left bound backwards.",
              code: "function lengthOfLongestSubstring(s) {\n  const last = new Map();\n  let left = 0, best = 0;\n  for (let right = 0; right < s.length; right++) {\n    if (last.has(s[right])) left = Math.max(left, last.get(s[right]) + 1);\n    last.set(s[right], right);\n    best = Math.max(best, right - left + 1);\n  }\n  return best;\n}"),
        .init(title: "Number of Islands", slug: "number-of-islands",
              content: "Count groups of horizontally or vertically connected land cells in a binary grid.",
              intuition: "Start a flood fill at each unvisited land cell. Mark cells as water to avoid counting them twice.",
              code: "function numIslands(grid) {\n  if (!grid.length) return 0;\n  function visit(r, c) {\n    if (r < 0 || c < 0 || r >= grid.length || c >= grid[0].length || grid[r][c] !== '1') return;\n    grid[r][c] = '0';\n    visit(r + 1, c); visit(r - 1, c); visit(r, c + 1); visit(r, c - 1);\n  }\n  let count = 0;\n  for (let r = 0; r < grid.length; r++) {\n    for (let c = 0; c < grid[r].length; c++) {\n      if (grid[r][c] === '1') { count++; visit(r, c); }\n    }\n  }\n  return count;\n}"),
        .init(title: "Merge Intervals", slug: "merge-intervals",
              content: "Merge overlapping intervals and return the resulting non-overlapping intervals.",
              intuition: "Sort by start time. Merge into the last result interval whenever the next start is within its end.",
              code: "function merge(intervals) {\n  intervals.sort((a, b) => a[0] - b[0]);\n  const result = [];\n  for (const [start, end] of intervals) {\n    const last = result[result.length - 1];\n    if (last && start <= last[1]) last[1] = Math.max(last[1], end);\n    else result.push([start, end]);\n  }\n  return result;\n}")
    ]
}
