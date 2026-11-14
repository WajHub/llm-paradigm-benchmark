The compile error comes from the package line I added, "package com.example.btree;", since the files sit in the default package and are compiled directly with javac. That mismatch explains why BTreeImpl can't see BTree. I also need to reference Node as the nested class BTree.Node, which the subclass can reach through inheritance. I'll drop the package line and leave the rest alone.

The package line is the problem, so I'll remove it.


