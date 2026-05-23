using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace PetCompanion.Windows.Platform;

public enum TaskbarEdge
{
    Left,
    Top,
    Right,
    Bottom
}

public sealed record TaskbarLayout(
    Rectangle ScreenBounds,
    Rectangle TaskbarBounds,
    TaskbarEdge Edge,
    double Baseline);

public sealed class TaskbarTracker
{
    private const double PetOffset = 13;

    public TaskbarLayout CurrentLayout()
    {
        var data = new NativeMethods.APPBARDATA
        {
            cbSize = Marshal.SizeOf<NativeMethods.APPBARDATA>()
        };
        NativeMethods.SHAppBarMessage(NativeMethods.ABM_GETTASKBARPOS, ref data);

        var taskbar = Rectangle.FromLTRB(data.rc.left, data.rc.top, data.rc.right, data.rc.bottom);
        if (taskbar.Width <= 0 || taskbar.Height <= 0)
        {
            var fallback = Screen.PrimaryScreen?.Bounds ?? new Rectangle(0, 0, 1280, 720);
            taskbar = new Rectangle(fallback.Left, fallback.Bottom - 48, fallback.Width, 48);
        }

        var screen = Screen.FromRectangle(taskbar).Bounds;
        var edge = InferEdge(screen, taskbar);
        var baseline = edge switch
        {
            TaskbarEdge.Bottom => taskbar.Top - screen.Top + PetOffset,
            TaskbarEdge.Top => taskbar.Bottom - screen.Top - PetOffset,
            TaskbarEdge.Left => taskbar.Right - screen.Left + PetOffset,
            TaskbarEdge.Right => taskbar.Left - screen.Left - PetOffset,
            _ => taskbar.Top - screen.Top + PetOffset
        };

        return new TaskbarLayout(screen, taskbar, edge, baseline);
    }

    private static TaskbarEdge InferEdge(Rectangle screen, Rectangle taskbar)
    {
        if (taskbar.Width >= taskbar.Height)
        {
            var distanceToTop = Math.Abs(taskbar.Top - screen.Top);
            var distanceToBottom = Math.Abs(taskbar.Bottom - screen.Bottom);
            return distanceToTop < distanceToBottom ? TaskbarEdge.Top : TaskbarEdge.Bottom;
        }

        var distanceToLeft = Math.Abs(taskbar.Left - screen.Left);
        var distanceToRight = Math.Abs(taskbar.Right - screen.Right);
        return distanceToLeft < distanceToRight ? TaskbarEdge.Left : TaskbarEdge.Right;
    }
}
