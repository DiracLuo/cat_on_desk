using System;
using System.Windows;
using PetCompanion.Windows.Platform;

namespace PetCompanion.Windows.Pet;

public sealed class PetMovementController
{
    private TaskbarEdge edge = TaskbarEdge.Bottom;
    private double baseline = 13;
    private Point? homePosition;

    public double Direction { get; private set; } = 1;

    public void Configure(TaskbarEdge edge, double baseline)
    {
        this.edge = edge;
        this.baseline = baseline;
    }

    public Point StartingPosition(Size sceneSize, Size petSize)
    {
        var position = edge switch
        {
            TaskbarEdge.Bottom => new Point(Math.Max(petSize.Width, sceneSize.Width * 0.5), baseline),
            TaskbarEdge.Top => new Point(Math.Max(petSize.Width, sceneSize.Width * 0.5), baseline),
            TaskbarEdge.Left => new Point(baseline, Math.Max(petSize.Height, sceneSize.Height * 0.5)),
            TaskbarEdge.Right => new Point(baseline, Math.Max(petSize.Height, sceneSize.Height * 0.5)),
            _ => new Point(Math.Max(petSize.Width, sceneSize.Width * 0.5), baseline)
        };
        homePosition = position;
        return position;
    }

    public Point TaskbarAlignedPosition(Point currentPosition, Size sceneSize, Size petSize)
    {
        var next = currentPosition;
        switch (edge)
        {
            case TaskbarEdge.Bottom:
            case TaskbarEdge.Top:
                next.X = Clamp(next.X, petSize.Width * 0.55, sceneSize.Width - petSize.Width * 0.55);
                next.Y = baseline;
                break;
            case TaskbarEdge.Left:
            case TaskbarEdge.Right:
                next.X = baseline;
                next.Y = Clamp(next.Y, petSize.Height * 0.55, sceneSize.Height - petSize.Height * 0.55);
                break;
        }
        homePosition = ClampHome(homePosition ?? next, sceneSize, petSize);
        return next;
    }

    public Point SetHomePosition(Point position, Size sceneSize, Size petSize)
    {
        var clamped = ClampFreePosition(position, sceneSize, petSize);
        homePosition = clamped;
        return clamped;
    }

    public Point Update(Point position, Size sceneSize, Size petSize, double speed, double deltaTime)
    {
        var next = position;
        var distance = speed * deltaTime;
        var bounds = WalkingBounds(sceneSize, petSize);

        if (edge is TaskbarEdge.Bottom or TaskbarEdge.Top)
        {
            next.X += Direction * distance;
            if (next.X <= bounds.Min)
            {
                next.X = bounds.Min;
                Direction = 1;
            }
            else if (next.X >= bounds.Max)
            {
                next.X = bounds.Max;
                Direction = -1;
            }
        }
        else
        {
            next.Y += Direction * distance;
            if (next.Y <= bounds.Min)
            {
                next.Y = bounds.Min;
                Direction = 1;
            }
            else if (next.Y >= bounds.Max)
            {
                next.Y = bounds.Max;
                Direction = -1;
            }
        }

        return next;
    }

    private (double Min, double Max) WalkingBounds(Size sceneSize, Size petSize)
    {
        if (edge is TaskbarEdge.Bottom or TaskbarEdge.Top)
        {
            var fullMin = petSize.Width * 0.55;
            var fullMax = Math.Max(fullMin, sceneSize.Width - petSize.Width * 0.55);
            var center = ClampHome(homePosition ?? new Point(sceneSize.Width * 0.5, baseline), sceneSize, petSize).X;
            var halfRange = sceneSize.Width / 6;
            return (Math.Max(fullMin, center - halfRange), Math.Min(fullMax, center + halfRange));
        }
        else
        {
            var fullMin = petSize.Height * 0.55;
            var fullMax = Math.Max(fullMin, sceneSize.Height - petSize.Height * 0.55);
            var center = ClampHome(homePosition ?? new Point(baseline, sceneSize.Height * 0.5), sceneSize, petSize).Y;
            var halfRange = sceneSize.Height / 6;
            return (Math.Max(fullMin, center - halfRange), Math.Min(fullMax, center + halfRange));
        }
    }

    private Point ClampHome(Point position, Size sceneSize, Size petSize)
    {
        return edge switch
        {
            TaskbarEdge.Bottom or TaskbarEdge.Top => new Point(
                Clamp(position.X, petSize.Width * 0.55, sceneSize.Width - petSize.Width * 0.55),
                baseline),
            TaskbarEdge.Left or TaskbarEdge.Right => new Point(
                baseline,
                Clamp(position.Y, petSize.Height * 0.55, sceneSize.Height - petSize.Height * 0.55)),
            _ => position
        };
    }

    private static Point ClampFreePosition(Point position, Size sceneSize, Size petSize)
    {
        return new Point(
            Clamp(position.X, petSize.Width * 0.55, sceneSize.Width - petSize.Width * 0.55),
            Clamp(position.Y, petSize.Height * 0.55, sceneSize.Height - petSize.Height * 0.55));
    }

    private static double Clamp(double value, double min, double max) => Math.Min(Math.Max(value, min), max);
}
