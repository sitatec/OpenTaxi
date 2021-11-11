package com.hamba.dispatcher.geometry

import dilivia.s2.S1Angle
import dilivia.s2.S1ChordAngle
import dilivia.s2.S2Point
import dilivia.s2.edge.S2EdgeDistances
import dilivia.s2.index.*
import dilivia.s2.index.shape.S2ShapeIndex
import dilivia.s2.region.S2Cell
import dilivia.s2.region.S2Region


/**
 * A custom version of `S2ClosestPointQuery`
 */
class ClosestPointQuery<T : Comparable<T>> {
    // See ClosestPointQueryBase for full documentation.
    private lateinit var options: Options
    private val base: ClosestPointQueryBase<S2MinDistance, T> = ClosestPointQueryBase(S2MinDistanceFactory)

    // Convenience constructor that calls Init().  Options may be specified here
    // or changed at any time using the mutable_options() accessor method.
    constructor(index: PointIndex<T>, options: Options = Options()) {
        init(index, options)
    }

    // Default constructor; requires Init() to be called.
    constructor() {
        TODO()
    }

    // Initializes the query.  Options may be specified here or changed at any
    // time using the mutable_options() accessor method.
    //
    // REQUIRES: "index" must persist for the lifetime of this object.
    // REQUIRES: ReInit() must be called if "index" is modified.
    fun init(index: PointIndex<T>, options: Options = Options()) {
        this.options = options
        base.init(index)
    }

    // Reinitializes the query.  This method must be called whenever the
    // underlying index is modified.
    fun reInit() {
        base.reInit()
    }

    // Returns a reference to the underlying PointIndex.
    fun index(): PointIndex<T> = base.index()

    fun options(): Options = options

    // Returns the closest points to the given target that satisfy the current
    // options.  This method may be called multiple times.
    fun findClosestPoints(target: S2MinDistanceTarget): List<ClosestPointQueryBase.Result<S2MinDistance, T>> = base.findClosestPoints(target, options)

    // This version can be more efficient when this method is called many times,
    // since it does not require allocating a new vector on each call.
    fun findClosestPoints(target: S2MinDistanceTarget, results: MutableList<ClosestPointQueryBase.Result<S2MinDistance, T>>) {
        base.findClosestPoints(target, options, results)
    }

    //////////////////////// Convenience Methods ////////////////////////

    // Returns the closest point to the target.  If no point satisfies the search
    // criteria, then a Result object with distance() == Infinity() and
    // is_empty() == true is returned.
    fun findClosestPoint(target: S2MinDistanceTarget): ClosestPointQueryBase.Result<S2MinDistance, T> {
        val tmpOptions = options.clone()
        tmpOptions.setMaxResult(1)
        return base.findClosestPoint(target, tmpOptions)
    }

    // Returns the minimum distance to the target.  If the index or target is
    // empty, returns S1ChordAngle::Infinity().
    //
    // Use IsDistanceLess() if you only want to compare the distance against a
    // threshold value, since it is often much faster.
    fun getDistance(target: S2MinDistanceTarget): S1ChordAngle = findClosestPoint(target).distance.value

    // Returns true if the distance to "target" is less than "limit".
    //
    // This method is usually much faster than GetDistance(), since it is much
    // less work to determine whether the minimum distance is above or below a
    // threshold than it is to calculate the actual minimum distance.
    fun isDistanceLess(target: S2MinDistanceTarget, limit: S1ChordAngle): Boolean {
        val tmpOptions = options.clone()
        tmpOptions.setMaxResult(1)
        tmpOptions.maxDistance = S2MinDistance(limit)
        tmpOptions.maxError = S1ChordAngle.straight()
        return !base.findClosestPoint(target, tmpOptions).isEmpty()
    }

    // Like IsDistanceLess(), but also returns true if the distance to "target"
    // is exactly equal to "limit".
    fun isDistanceLessOrEqual(target: S2MinDistanceTarget, limit: S1ChordAngle): Boolean {
        val tmp_options = options.clone()
        tmp_options.setMaxResult(1)
        tmp_options.setInclusiveMaxDistance(limit)
        tmp_options.maxError  = S1ChordAngle.straight()
        return !base.findClosestPoint(target, tmp_options).isEmpty()
    }

    // Like IsDistanceLessOrEqual(), except that "limit" is increased by the
    // maximum error in the distance calculation.  This ensures that this
    // function returns true whenever the true, exact distance is less than
    // or equal to "limit".
    //
    // For example, suppose that we want to test whether two geometries might
    // intersect each other after they are snapped together using S2Builder
    // (using the IdentitySnapFunction with a given "snap_radius").  Since
    // S2Builder uses exact distance predicates (s2predicates.h), we need to
    // measure the distance between the two geometries conservatively.  If the
    // distance is definitely greater than "snap_radius", then the geometries
    // are guaranteed to not intersect after snapping.
    fun isConservativeDistanceLessOrEqual(target: S2MinDistanceTarget, limit: S1ChordAngle): Boolean {
        val tmpOptions = options.clone()
        tmpOptions.setMaxResult(1)
        tmpOptions.setConservativeMaxDistance(limit)
        tmpOptions.maxError = S1ChordAngle.straight()
        return !base.findClosestPoint(target, tmpOptions).isEmpty()
    }

    // Options that control the set of points returned.  Note that by default
    // *all* points are returned, so you will always want to set either the
    // max_results() option or the max_distance() option (or both).
    //
    // This class is also available as S2ClosestPointQuery<Data>::Options.
    // (It is defined here to avoid depending on the "Data" template argument.)
    class Options() : ClosestPointQueryBase.Options<S2MinDistance>(S2MinDistanceFactory), Cloneable {

        constructor(maxResult: Int = kMaxMaxResults,
                    maxDistance: S2MinDistance = S2MinDistanceFactory.infinity(),
                    maxError: Delta = Delta.zero(),
                    region: S2Region? = null,
                    useBruteForce: Boolean = false): this() {
            this.setMaxResult(maxResult)
            this.maxDistance = maxDistance
            this.maxError = maxError
            this.region = region
            this.useBruteForce = useBruteForce
        }

        // See ClosestPointQueryBaseOptions for the full set of options.

        // Specifies that only points whose distance to the target is less than
        // "max_distance" should be returned.
        //
        // Note that points whose distance is exactly equal to "max_distance" are
        // not returned.  Normally this doesn't matter, because distances are not
        // computed exactly in the first place, but if such points are needed then
        // see set_inclusive_max_distance() below.
        //
        // DEFAULT: Distance::Infinity()
        fun setMaxDistance(maxDistance: S1ChordAngle) {
            this.maxDistance = S2MinDistance(maxDistance)
        }

        // Like set_max_distance(), except that points whose distance is exactly
        // equal to "max_distance" are also returned.  Equivalent to calling
        // set_max_distance(max_distance.Successor()).
        fun setInclusiveMaxDistance(maxDistance: S1ChordAngle) {
            setMaxDistance(maxDistance.successor())
        }

        // Like set_inclusive_max_distance(), except that "max_distance" is also
        // increased by the maximum error in the distance calculation.  This ensures
        // that all points whose true distance is less than or equal to
        // "max_distance" will be returned (along with some points whose true
        // distance is slightly greater).
        //
        // Algorithms that need to do exact distance comparisons can use this
        // option to find a set of candidate points that can then be filtered
        // further (e.g., using s2pred::CompareDistance).
        fun setConservativeMaxDistance(maxDistance: S1ChordAngle): Unit {
            this.maxDistance = S2MinDistance(maxDistance.plusError(S2EdgeDistances.getUpdateMinDistanceMaxError(maxDistance)).successor())
        }

        // Versions of set_max_distance that take an S1Angle argument.  (Note that
        // these functions require a conversion, and that the S1ChordAngle versions
        // are preferred.)
        fun setMaxDistance(maxDistance: S1Angle) {

        }

        fun setInclusiveMaxDistance(maxDistance: S1Angle) {
            setInclusiveMaxDistance(S1ChordAngle(maxDistance))
        }
        fun setConservativeMaxDistance(maxDistance: S1Angle): Unit {
            setConservativeMaxDistance(S1ChordAngle(maxDistance))
        }

        // See ClosestPointQueryBaseOptions for documentation.
        fun setMaxError(maxError: S1Angle) {
            this.maxError = S1ChordAngle(maxError)
        }

        public override fun clone(): Options {
            return Options(getMaxResult(), maxDistance.clone(), maxError, region, useBruteForce)
        }

    }

    // Target subtype that computes the closest distance to a point.
    //
    // This class is also available as S2ClosestPointQuery<Data>::PointTarget.
    // (It is defined here to avoid depending on the "Data" template argument.)
    class S2ClosestPointQueryPointTarget(point: S2Point) : S2MinDistancePointTarget(point) {

        override fun maxBruteForceIndexSize(): Int {
            // Using BM_FindClosest (which finds the single closest point), the
            // break-even points are approximately X, Y, and Z points for grid,
            // fractal, and regular loop geometry respectively.
            //
            // TODO(ericv): Adjust using benchmarks.
            return 150;
        }


    }

    // Target subtype that computes the closest distance to an edge.
    //
    // This class is also available as S2ClosestPointQuery<Data>::EdgeTarget.
    // (It is defined here to avoid depending on the "Data" template argument.)
    class S2ClosestPointQueryEdgeTarget(a: S2Point, b: S2Point) : S2MinDistanceEdgeTarget(a, b) {

        override fun maxBruteForceIndexSize(): Int {
            // Using BM_FindClosestToEdge (which finds the single closest point), the
            // break-even points are approximately X, Y, and Z points for grid,
            // fractal, and regular loop geometry respectively.
            //
            // TODO(ericv): Adjust using benchmarks.
            return 100;
        }

    }

    // Target subtype that computes the closest distance to an S2Cell
    // (including the interior of the cell).
    //
    // This class is also available as S2ClosestPointQuery<Data>::CellTarget.
    // (It is defined here to avoid depending on the "Data" template argument.)
    class S2ClosestPointQueryCellTarget(cell: S2Cell) : S2MinDistanceCellTarget(cell) {

        override fun maxBruteForceIndexSize(): Int {
            // Using BM_FindClosestToCell (which finds the single closest point), the
            // break-even points are approximately X, Y, and Z points for grid,
            // fractal, and regular loop geometry respectively.
            //
            // TODO(ericv): Adjust using benchmarks.
            return 5 //50;
        }

    }

    // Target subtype that computes the closest distance to an S2ShapeIndex
    // (an arbitrary collection of points, polylines, and/or polygons).
    //
    // By default, distances are measured to the boundary and interior of
    // polygons in the S2ShapeIndex rather than to polygon boundaries only.
    // If you wish to change this behavior, you may call
    //
    //   target.set_include_interiors(false);
    //
    // (see S2MinDistanceShapeIndexTarget for details).
    //
    // This class is also available as S2ClosestPointQuery<Data>::ShapeIndexTarget.
    // (It is defined here to avoid depending on the "Data" template argument.)
    class S2ClosestPointQueryShapeIndexTarget(index: S2ShapeIndex) : S2MinDistanceShapeIndexTarget(index) {

        override fun maxBruteForceIndexSize(): Int {
            // For BM_FindClosestToSameSizeAbuttingIndex (which uses a nearby
            // S2ShapeIndex target of similar complexity), the break-even points are
            // approximately X, Y, and Z points for grid, fractal, and regular loop
            // geometry respectively.
            //
            // TODO(ericv): Adjust using benchmarks.
            return 30;
        }

    }

}
