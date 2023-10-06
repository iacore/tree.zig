//! This file defines data structures for different types of trees:
//! splay trees and red-black trees.
//!
//! A splay tree is a self-organizing data structure.  Every operation
//! on the tree causes a splay to happen.  The splay moves the requested
//! node to the root of the tree and partly rebalances it.
//!
//! This has the benefit that request locality causes faster lookups as
//! the requested nodes move to the top of the tree.  On the other hand,
//! every lookup causes memory writes.
//!
//! The Balance Theorem bounds the total access time for m operations
//! and n inserts on an initially empty tree as O((m + n)lg n).  The
//! amortized cost for a sequence of m accesses to a splay tree is O(lg n);
//!
//! A red-black tree is a binary search tree with the node color as an
//! extra attribute.  It fulfills a set of conditions:
//! 	- every search path from the root to a leaf consists of the
//! 	  same number of black nodes,
//! 	- each red node (except for the root) has a black parent,
//! 	- each leaf node is black.
//!
//! Every operation on a red-black tree is bounded as O(lg n).
//! The maximum height of a red-black tree is 2lg (n+1).

const std = @import("std");

fn _Entry(comptime T: type) type {
    return struct {
        data: T,
        left: ?*@This() = null,
        right: ?*@This() = null,
    };
}

const WhichEnd = enum { min, max };

pub fn SplayTree(comptime T: type, comptime cmp: fn (T, T) std.math.Order) type {
    return struct {
        pub const Entry = _Entry(T);
        root: ?*Entry = null,

        pub fn init() @This() {
            return .{};
        }
        pub fn isEmpty(head: @This()) bool {
            return head.root == null;
        }

        pub fn min(head: *@This()) ?*Entry {
            if (head.isEmpty()) return null;
            minmax(head, .min);
            return head.root;
        }
        pub fn max(head: *@This()) ?*Entry {
            if (head.isEmpty()) return null;
            minmax(head, .max);
            return head.root;
        }
        pub fn find(head: *@This(), elm: T) ?*Entry {
            if (head.isEmpty()) return null;
            splay(head, elm);
            if (cmp(elm, head.root.?.data) == .eq) return head.root;
            return null;
        }
        pub fn next(head: *@This(), elm: *Entry) ?*Entry {
            splay(head, elm.data);
            if (elm.right) |elm_right| {
                var elm_ = elm_right;
                while (elm_.left) |elm_left| {
                    elm_ = elm_left;
                }
                return elm_;
            } else return null;
        }
        // returns if existing node exists
        pub fn insert(head: *@This(), elm: *Entry) ?*Entry {
            if (head.isEmpty()) {
                elm.left = null; // ???
                elm.right = null; // ???
            } else {
                splay(head, elm.data);
                switch (cmp(elm.data, head.root.?.data)) {
                    .lt => {
                        elm.left = head.root.?.left;
                        elm.right = head.root;
                        head.root.?.left = null;
                    },
                    .gt => {
                        elm.right = head.root.?.right;
                        elm.left = head.root;
                        head.root.?.right = null;
                    },
                    .eq => {
                        return head.root;
                    },
                }
            }
            head.root = elm;
            return null;
        }
        pub fn remove(head: *@This(), elm: *Entry) ?*Entry {
            if (head.isEmpty()) return null;
            splay(head, elm.data);
            if (cmp(elm.data, head.root.?.data) == .eq) {
                if (head.root.?.left == null) {
                    head.root = head.root.?.right;
                } else {
                    const tmp = head.root.?.right;
                    head.root = head.root.?.left;
                    splay(head, elm.data);
                    head.root.?.right = tmp;
                }
                return elm;
            }
            return null;
        }

        // rotate{Right,Left} expect that tmp hold {.right,.left}
        fn rotateRight(head: *@This(), tmp: *Entry) void {
            head.root.?.left = tmp.right;
            tmp.right = head.root;
            head.root = tmp;
        }
        fn rotateLeft(head: *@This(), tmp: *Entry) void {
            head.root.?.right = tmp.left;
            tmp.left = head.root;
            head.root = tmp;
        }
        fn linkLeft(head: *@This(), tmp: **Entry) void {
            tmp.*.left = head.root;
            tmp.* = head.root.?;
            head.root = head.root.?.left;
        }
        fn linkRight(head: *@This(), tmp: **Entry) void {
            tmp.*.right = head.root;
            tmp.* = head.root.?;
            head.root = head.root.?.right;
        }
        fn assemble(head: *@This(), node: *Entry, left: *Entry, right: *Entry) void {
            left.right = head.root.?.left;
            right.left = head.root.?.right;
            head.root.?.left = node.right;
            head.root.?.right = node.left;
        }

        fn splay(head: *@This(), elm: T) void {
            var node: Entry = undefined;
            node.left = null;
            node.right = null;

            var left: *Entry = &node;
            var right: *Entry = &node;
            var tmp: ?*Entry = undefined;

            var comp: std.math.Order = undefined;
            while (blk: {
                comp = cmp(elm, head.root.?.data);
                break :blk comp != .eq;
            }) {
                switch (comp) {
                    .lt => {
                        tmp = head.root.?.left;
                        if (tmp == null) break;
                        if (cmp(elm, tmp.?.data) == .lt) {
                            rotateRight(head, tmp.?);
                            if (head.root.?.left == null) break;
                        }
                        linkLeft(head, &right);
                    },
                    .gt => {
                        tmp = head.root.?.right;
                        if (tmp == null) break;
                        if (cmp(elm, tmp.?.data) == .gt) {
                            rotateLeft(head, tmp.?);
                            if (head.root.?.right == null) break;
                        }
                        linkRight(head, &left);
                    },
                    .eq => {},
                }
            }
            assemble(head, &node, left, right);
        }
        /// Splay with either the minimum or the maximum element
        /// Used to find minimum or maximum element in tree.
        fn minmax(head: *@This(), comp: WhichEnd) void {
            var node: Entry = undefined;
            node.left = null;
            node.right = null;

            var left: *Entry = &node;
            var right: *Entry = &node;
            var tmp: ?*Entry = undefined;

            while (true) {
                switch (comp) {
                    .min => {
                        tmp = head.root.?.left;
                        if (tmp == null) break;
                        if (comp == .min) { // ???
                            rotateRight(head, tmp.?);
                            if (head.root.?.left == null) break;
                        }
                        linkLeft(head, &right);
                    },
                    .max => {
                        tmp = head.root.?.right;
                        if (tmp == null) break;
                        if (comp == .max) { // ???
                            rotateLeft(head, tmp.?);
                            if (head.root.?.right == null) break;
                        }
                        linkRight(head, &left);
                    },
                }
            }
            assemble(head, &node, left, right);
        }
    };
}

const t = std.testing;

fn _cmp_Entry_u8(lhs: u8, rhs: u8) std.math.Order {
    return std.math.order(lhs, rhs);
}
test "foreach" {
    const Tree = SplayTree(u8, _cmp_Entry_u8);
    var tree = Tree.init();
    var arena = std.heap.ArenaAllocator.init(t.allocator);
    defer arena.deinit();
    for (0..10) |i| {
        const node = try arena.allocator().create(Tree.Entry);
        node.data = @intCast(i);
        const existing = tree.insert(node);
        try t.expectEqual(@as(?*Tree.Entry, null), existing);
    }

    // iterator
    {
        var i: u8 = 0;
        var x = tree.min();
        while (x) |_x| : ({
            x = tree.next(_x);
            i += 1;
        }) {
            try t.expectEqual(i, _x.data);
        }
    }

    // find
    for (0..10) |i| {
        const node = tree.find(@intCast(i));
        _ = node.?;
    }
}

test "how to free nodes correctly" {
    const Tree = SplayTree(u8, _cmp_Entry_u8);
    var tree = Tree.init();
    for (0..10) |i| {
        const node = try t.allocator.create(Tree.Entry);
        node.data = @intCast(i);
        const existing = tree.insert(node);
        try t.expectEqual(@as(?*Tree.Entry, null), existing);
    }
    var x = tree.min();
    while (x) |_x| {
        x = tree.next(_x); // must do it before the node is freed
        const _x_dup = tree.remove(_x);
        try t.expectEqual(_x, _x_dup.?);
        t.allocator.destroy(_x);
    }
}
