module duolist;
import std.range.interfaces: BidirectionalRange;


@nogc
class Dlist(T): BidirectionalRange {
    private {
        Node!(T)[2] ends = [null, null];
        alias head = ends[0];
        alias hind = ends[1];
        Node!(T) seek = null;
        size_t seekPos = 0;
    }
    size_t length;

    void pushHead(T val) { pushCap(0, Node!T(val)); length++;}
    void pushHind(T val) { pushCap(1, Node!T(val)); length++;}

    @nogc
    private void pushCap(byte a, Node!T node) {
        if (ends[a] is null) {
            ends[a] = node;
            assert(ends[1-a] == null);
            ends[1-a] = node;
            seek = node;
        }
        else {
            Node!(T) incumbent = ends[a];
            ends[a] = node;
            incumbent.adjacent[a] = node;
            node.adjacent[1-a] = incumbent;
            if (a == 0) seek++;
        }
    }
    
    T removeFallAhead() {} //Fall meaning where the seek goes when it's node is gone
    
    void removeNode(Node!T node) {
        foreach (a, n; node.adjacent) if (n is null) {
            assert(ends[1-a] == node);
            ends[1-a] = null;
        } else { //if adjacent is not null:
            n[1-a] = null;
        }
        destroy(node);
    }

    T popSeek() {

    }

    void insertBehind(T val) {insertSeekNode(0, Node!T(val)); }

    void insertSeekNode(byte a, Node!T node) {
        if (seek is null) {
            assert(ends == [null, null]);
            head = node;
            hind = node;
            seek = node;
            length = 1;
            seekPos = 0;
            return;
        }
        node.adjacent[a] = seek.adjacent[a];
        node.adjacent[1-a] = seek.adjacent[a].adjacent[1-a];
        if (seek.adjacent[a] is null) {
            ends[1-a] = node;
        }
        else {
            seek.adjacent[a].adjacent[1-a] = node;
        }
        seek.adjacent[a] = node;
        if (a == 0) seekPos++;
        seekDir(a);
    }

    bool seekDir(byte a) {
        if (a == 1) seekPos++;
        else seekPos--;
        seek = seek.adjacent[a];
    }

    bool intoEmptyList(Node!T node) {
        validate();
        if (seek is null && ends == [null, null]) {
            head = node;
            hind = node;
            seek = node;
            length = 1;
            seekPos = 0;
            return;
        }
    }

    private void validate() {
        assert( (seek  is null && head  is null && hind  is null && length == 0 && seekPos == 0)
        ||      (seek !is null && head !is null && hind !is null && length  > 0) );
    }
}


@nogc
class Node(T) {
    Node!(T)*[2] adjacent = [null, null];
    alias ahead = adjacent[0];
    alias behind = adjacent[1];
    T val;
    alias val this;

    this(T v) {
        val = v;
    }

    ~this() {
        destroy(val);
    }
}
