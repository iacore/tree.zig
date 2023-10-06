Zig rewrite of https://github.com/openbsd/src/raw/master/sys/sys/tree.h

Data structures ported

- [x] splay tree
- [ ] red-black tree (you may want to use [AVL tree](https://github.com/avdva/zigavl) instead)

Note about SplayTree: there is [potential footgun](https://man.openbsd.org/tree.3) when freeing nodes of a tree. See `test "how to free nodes correctly"` in [src/main.zig](src/main.zig) for correct usage.

