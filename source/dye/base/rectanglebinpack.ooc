
/**
 * From: http://clb.demon.fi/files/RectangleBinPack/RectangleBinPack.h
 * 
 * Performs 'discrete online rectangle packing into a rectangular bin' by maintaining 
 * a binary tree of used and free rectangles of the bin. There are several variants
 * of bin packing problems, and this packer is characterized by:
 * - We're solving the 'online' version of the problem, which means that when we're adding
 *   a rectangle, we have no information of the sizes of the rectangles that are going to
 *   be packed after this one.
 * - We are packing rectangles that are not rotated. I.e. the algorithm will not flip
 *   a rectangle of (w,h) to be stored if it were a rectangle of size (h, w). There is no
 *   restriction conserning UV mapping why this couldn't be done to achieve better
 *   occupancy, but it's more work. Feel free to try it out.
 * - The packing is done in discrete integer coordinates and not in rational/real numbers (floats).
 *
 * Internal memory usage is linear to the number of rectangles we've already packed.
 *
 * For more information, see
 * - Rectangle packing: http://www.gamedev.net/community/forums/topic.asp?topic_id=392413
 * - Packing lightmaps: http://www.blackpawn.com/texts/lightmaps/default.html
 * 
 * Idea: Instead of just picking the first free rectangle to insert the new rect into,
 *       check all free ones (or maintain a sorted order) and pick the one that minimizes 
 *     the resulting leftover area. There is no real reason to maintain a tree - in fact 
 *     it's just redundant structuring. We could as well have two lists - one for free 
 *     rectangles and one for used rectangles. This method would be faster and might
 *     even achieve a considerably better occupancy rate.
 */
RectangleBinPack: class {

    root: BinNode
    binWidth, binHeight: Int

    /**
     * Restarts the packing process, clearing all previously packed rectangles
     * and sets up a new bin of a given initial size. These bin dimensions stay
     * fixed during the whole packing process, i.e. to change the bin size,
     * the packing must be restarted again with a new call to Init().
     */
    init: func (=binWidth, =binHeight) {
        // create root node
        root = BinNode new()
        root left = 0
        root right = 0
        root x = 0
        root y = 0
        root width = binWidth
        root height = binHeight
    }
    
    /**
     * @return A value [0, 1] denoting the ratio of total surface area that
     * is in use.  0.0f - the bin is totally empty, 1.0f - the bin is full.
     */
    occupancy: func -> Float {
        totalSurfaceArea: ULong = binWidth * binHeight
        usedSurfaceArea: ULong = usedSurfaceArea(root)

        return (usedSurfaceArea as Float) / (totalSurfaceArea as Float)
    }

    /**
     * @return The surface area used by the subtree rooted at node. (recursive)
     */
    usedSurfaceArea: func (node: BinNode) -> ULong {
        if (node left || node right) {
            usedSurfaceArea: ULong = node width * node height
            if (node left) {
                usedSurfaceArea += usedSurfaceArea(node left)
            }
            if (node right) {
                usedSurfaceArea += usedSurfaceArea(node right)
            }
            return usedSurfaceArea
        }

        // this is a leaf node, it doesn't constitute to the total surface area
        0
    }

    /** Running time is linear to the number of rectangles already packed.
     * Recursively calls itself.
     * @return null If the insertion didn't succeed.
     */
    insert: func (node: BinNode, width, height: Int) -> BinNode {
        // If this node is an internal node, try both leaves for possible space.
        // (The rectangle in an internal node stores used space, the leaves store free space)
        if (node left || node right) {
            if (node left) {
                newNode := insert(node left, width, height)
                if (newNode) return newNode
            }
            if (node right) {
                newNode := insert(node right, width, height)
                if (newNode) return newNode
            }
            return null // Didn't fit into either subtree!
        }

        // This node is a leaf, but can we fit the new rectangle here?
        if (width > node width || height > node height) {
            return null // Too bad, no space.
        }

        // The new cell will fit, split the remaining space along the shorter axis,
        // that is probably more optimal.
        w := node width - width
        h := node height - height
        node left = BinNode new()
        node right = BinNode new()
        if (w <= h) { // Split the remaining space in horizontal direction.
            node left x = node x + width
            node left y = node y
            node left width = w
            node left height = height

            node right x = node x
            node right y = node y + height
            node right width = node width
            node right height = h
        } else { // Split the remaining space in vertical direction.
            node left x = node x
            node left y = node y + height
            node left width = width
            node left height = h

            node right x = node x + width
            node right y = node y
            node right width = w
            node right height = node height
        }
        // Note that as a result of the above, it can happen that node left or node right
        // is now a degenerate (zero area) rectangle. No need to do anything about it,
        // like remove the nodes as "unnecessary" since they need to exist as children of
        // this node (this node can't be a leaf anymore).

        // This node is now a non-leaf, so shrink its area - it now denotes
        // *occupied* space instead of free space. Its children spawn the resulting
        // area of free space.
        node width = width
        node height = height
        return node
    }

}

BinNode: class {
    left, right: This
    x, y: Int
    width, height: Int

    init: func
}

