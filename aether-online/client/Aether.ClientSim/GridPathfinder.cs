namespace Aether.ClientSim;

public static class GridPathfinder
{
    private static readonly (int Column, int Row)[] Neighbors =
    [
        (1, 0),
        (-1, 0),
        (0, 1),
        (0, -1),
        (1, 1),
        (1, -1),
        (-1, 1),
        (-1, -1),
    ];

    public static IReadOnlyList<PlanarPoint> Find(WalkGrid grid, PlanarPoint from, PlanarPoint to)
    {
        if (!grid.IsWalkable(from) || !grid.IsWalkable(to))
        {
            return Array.Empty<PlanarPoint>();
        }

        _ = grid.TryWorldToCell(from, out var startColumn, out var startRow);
        _ = grid.TryWorldToCell(to, out var goalColumn, out var goalRow);
        if (!grid.IsOpen(startColumn, startRow) || !grid.IsOpen(goalColumn, goalRow))
        {
            return Array.Empty<PlanarPoint>();
        }

        var start = (startColumn, startRow);
        var goal = (goalColumn, goalRow);
        if (start == goal)
        {
            return new[] { grid.CellCenter(startColumn, startRow) };
        }

        var open = new PriorityQueue<(int Column, int Row), float>();
        var cameFrom = new Dictionary<(int Column, int Row), (int Column, int Row)>();
        var cost = new Dictionary<(int Column, int Row), float> { [start] = 0f };
        var closed = new HashSet<(int Column, int Row)>();
        open.Enqueue(start, Heuristic(start, goal));

        while (open.Count > 0)
        {
            var current = open.Dequeue();
            if (!closed.Add(current))
            {
                continue;
            }

            if (current == goal)
            {
                return Reconstruct(grid, cameFrom, current);
            }

            foreach (var (columnStep, rowStep) in Neighbors)
            {
                var nextColumn = current.Column + columnStep;
                var nextRow = current.Row + rowStep;
                if (!grid.IsOpen(nextColumn, nextRow))
                {
                    continue;
                }

                if (columnStep != 0 && rowStep != 0
                    && (!grid.IsOpen(current.Column + columnStep, current.Row)
                        || !grid.IsOpen(current.Column, current.Row + rowStep)))
                {
                    continue;
                }

                var currentCenter = grid.CellCenter(current.Column, current.Row);
                var nextCenter = grid.CellCenter(nextColumn, nextRow);
                if (grid.Layout.SegmentHitsBlocked(currentCenter, nextCenter))
                {
                    continue;
                }

                var stepCost = columnStep != 0 && rowStep != 0 ? 1.41421356f : 1f;
                var tentative = cost[current] + stepCost;
                var next = (nextColumn, nextRow);
                if (cost.TryGetValue(next, out var known) && tentative >= known)
                {
                    continue;
                }

                cameFrom[next] = current;
                cost[next] = tentative;
                open.Enqueue(next, tentative + Heuristic(next, goal));
            }
        }

        return Array.Empty<PlanarPoint>();
    }

    public static bool TryFindDetour(WalkGrid grid, PlanarPoint from, out PlanarPoint goal, out IReadOnlyList<PlanarPoint> path)
    {
        goal = default;
        path = Array.Empty<PlanarPoint>();
        if (!grid.IsWalkable(from))
        {
            return false;
        }

        var bestDistance = 0f;
        for (var row = 0; row < grid.Rows; row++)
        {
            for (var column = 0; column < grid.Columns; column++)
            {
                if (!grid.IsOpen(column, row))
                {
                    continue;
                }

                var candidate = grid.CellCenter(column, row);
                var distance = from.DistanceTo(candidate);
                if (distance < bestDistance || distance < MathF.Min(grid.Layout.SizeX, grid.Layout.SizeZ) * 0.35f)
                {
                    continue;
                }

                if (!grid.Layout.SegmentHitsBlocked(from, candidate))
                {
                    continue;
                }

                var candidatePath = Find(grid, from, candidate);
                if (candidatePath.Count < 2 || PathHitsBlocked(grid.Layout, candidatePath))
                {
                    continue;
                }

                bestDistance = distance;
                goal = candidate;
                path = candidatePath;
            }
        }

        return path.Count >= 2;
    }

    public static bool PathHitsBlocked(MapLayout layout, IReadOnlyList<PlanarPoint> path)
    {
        for (var i = 1; i < path.Count; i++)
        {
            if (layout.SegmentHitsBlocked(path[i - 1], path[i]))
            {
                return true;
            }
        }

        return false;
    }

    private static float Heuristic((int Column, int Row) from, (int Column, int Row) to)
    {
        var columnDelta = Math.Abs(from.Column - to.Column);
        var rowDelta = Math.Abs(from.Row - to.Row);
        var diagonal = Math.Min(columnDelta, rowDelta);
        var straight = Math.Max(columnDelta, rowDelta) - diagonal;
        return (diagonal * 1.41421356f) + straight;
    }

    private static IReadOnlyList<PlanarPoint> Reconstruct(
        WalkGrid grid,
        Dictionary<(int Column, int Row), (int Column, int Row)> cameFrom,
        (int Column, int Row) current)
    {
        var cells = new List<(int Column, int Row)> { current };
        while (cameFrom.TryGetValue(current, out var previous))
        {
            current = previous;
            cells.Add(current);
        }

        cells.Reverse();
        var points = new PlanarPoint[cells.Count];
        for (var i = 0; i < cells.Count; i++)
        {
            points[i] = grid.CellCenter(cells[i].Column, cells[i].Row);
        }

        return points;
    }
}
