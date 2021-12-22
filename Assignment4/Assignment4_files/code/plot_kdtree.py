import argparse
import boundingbox as bb
import database as db
import data_loader as dl
import kdtree as kd
import plotter as pl
import numpy as np

# lab
import quadtree as qt

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='KDTree plotting program.')

    parser.add_argument('--filename', help='file containing spatial information.', type=str)
    parser.add_argument('--max-depth', help='the maximum depth of the KDTree.', type=int, default=3)
    parser.add_argument('--max-elements', help='the maximum of elements in a KDTree leave.', type=int, default=1000)
    parser.add_argument('--bbox-depth', help='display the bounding-boxes at specific depth.', type=int, default=2)
    parser.add_argument('--plot', help='choose what to plot (kdtree-bb,storage)', type=str, default="kdtree-bb")
    parser.add_argument('--range-query', help='bbox range query, "1 2; 3 4"', type=str)
    parser.add_argument('--closest', help='closest point query, "1 2"', type=str)
    parser.add_argument('--quadtree', help='add quadtree indexing depth, 2', type=int)
    parser.add_argument('--quadlevel', help='select all points up to this level, 2', type=int)
    parser.add_argument('--quadshow', help='display the quadtree', type=bool, default=False)

    args = parser.parse_args()

    # Construct database
    fields = ["x", "y"]
    if args.quadtree:
        fields.append("quad")
    dtb = db.Database(fields)
    field_idx = dtb.fields()

    # Load the data
    data_loader = dl.DataLoader()
    data_loader.load(args, dtb)

    # Create KDTree
    tree = kd.KDTree(dtb, {'max-depth': args.max_depth, 'max-elements': args.max_elements})

    plotter = pl.Plotter(tree, dtb, args)

    # Testing: Implementing the QuadTree
    if args.quadtree:
        quadtree = qt.QuadTree(tree.bounding_box(), args.quadtree)
        if args.quadshow:
            plotter.add_quadtree(quadtree)

    # Testing: Implementing the KDTree
    if args.closest:
        # This is for testing, to check if your closest query is correclty implemented

        # Step 1 query and fetch
        closest_query = np.fromstring(args.closest, dtype=float, sep=' ')
        closest_records = dtb.query(tree.closest(closest_query))

        # Step 2 compare found geometry with closest_point
        geometries = [[x[field_idx["x"]], x[field_idx["y"]]] for x in closest_records]
        distances = [np.linalg.norm(closest_query - geom) for geom in geometries]
        ordered = np.argsort(distances)

        # Step 3 plot search and result point
        plotter.add_closest_query(closest_query, geometries[ordered[0]])

    # Using the QuadTree depth to subsample the KDTree
    if args.quadtree:

        # Step 1: set quad levels to max-depth for all records.
        for key in dtb.keys():
            dtb.update_field(key, 'quad', args.max_depth)

        # Step 2: iterate through the quad tree in reverse order.
        for level in range(args.quadtree-1, -1, -1):

            # Step 3: for each box in the level, get the centroid.
            for bbox in quadtree.quads[level]:

                # Step 4: and use the centroid to get the list of the closest points from the KDTree.
                closest_idxs = tree.closest(bbox.centroid())

                # Step 5: within this list, find the actual closest point.
                closest_records = dtb.query(closest_idxs)
                nodes = np.asarray([[record[1], record[2]] for record in closest_records])
                dist_2 = np.sum((nodes - bbox.centroid()) ** 2, axis=1)
                closest_idx = closest_idxs[np.argmin(dist_2)]

                # Step 6: update the `quad` field of the closest record to the current quad level.
                dtb.update_field(closest_idx, 'quad', level)

    plotter.plot()
