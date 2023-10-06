Zig rewrite of [trees from OpenBSD](https://github.com/openbsd/src/raw/master/sys/sys/tree.h).

Data structures ported

- [x] splay tree 
- [ ] red-black tree (you may want to use [AVL tree](https://github.com/avdva/zigavl) instead)

## Usage

See [src/main.zig](src/main.zig) for usage.

To use this library in your project, copy the file into your project and rename it as `tree.zig` or something.

### Note about splay tree

There is [potential footgun](https://man.openbsd.org/tree.3) when freeing nodes of a tree. See `test "how to free nodes correctly"` in [src/main.zig](src/main.zig) for correct usage.

Enhancements over the original:

- proper generic type
- `tree.prev(node)`

Also, the original C impl has some weird design choices, which I will not touch.

Also, invalid data given to the public API will not crash the program.

