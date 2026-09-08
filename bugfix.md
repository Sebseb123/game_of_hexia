# Node Initialization Bug

## Problem

The board contains 19 hexagons. Each hexagon contributes six corners, so the initial node collection contains 114 corner instances. On a standard Catan board, shared corners must be merged into 54 unique nodes. The current `initNodes()` method returns 100 nodes instead.

## Cause

The `Set<Node>` implementation is working correctly. Nodes are merged when their coordinates are equal because `Node` overrides equality and `hashCode` based on its coordinates.

The problem is that logical hexagon coordinates are being used directly as geometric center coordinates. The hexagon corner offsets describe a hexagon with a width of 0.5 and a height of 1.0, but neighboring logical hexagons are separated by whole integer coordinate units. As a result, only some neighboring hexagons calculate identical corner positions. Most corners that should represent the same board node receive different coordinates and remain separate entries in the set.

## Required Fix

Logical hexagon coordinates and geometric drawing coordinates must be treated as two separate coordinate systems.

The integer x/y coordinates should continue to identify hexagons and determine their logical neighbors. Before calculating the six corners, those coordinates must be converted into geometric center positions that match the chosen hexagon dimensions and orientation.

With the current corner layout, a logical horizontal movement corresponds to approximately 0.75 geometric units horizontally and 0.5 geometric units vertically. A logical vertical movement corresponds to one geometric unit vertically.

After this conversion, adjacent hexagons will calculate exactly matching coordinates for their shared corners. The existing `Set<Node>` deduplication will then produce the expected 54 unique nodes for the 19-hexagon board.

## Verification

The fix is correct when:

- The board still contains 19 hexagons.
- Six corner instances are generated for each hexagon.
- Shared corners are merged by the node set.
- `initNodes()` returns 54 unique nodes.
- Nodes on the board boundary have one or two adjacent hexagons.
- Interior nodes have three adjacent hexagons.
