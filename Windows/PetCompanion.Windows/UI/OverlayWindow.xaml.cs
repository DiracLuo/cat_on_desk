using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Interop;
using System.Windows.Media;
using System.Windows.Threading;
using PetCompanion.Windows.Pet;
using PetCompanion.Windows.Platform;

namespace PetCompanion.Windows.UI;

public partial class OverlayWindow : Window
{
    private readonly TaskbarTracker taskbarTracker;
    private readonly AppPreferences preferences;
    private readonly CatSpriteLibrary spriteLibrary;
    private readonly PetStateMachine stateMachine;
    private readonly PetMovementController movementController = new();
    private readonly DispatcherTimer frameTimer = new();
    private readonly DispatcherTimer taskbarTimer = new();
    private readonly Size petSize = new(118, 94);
    private TaskbarLayout? currentLayout;
    private Point petPosition;
    private DateTime startedAt = DateTime.UtcNow;
    private DateTime lastFrameAt = DateTime.UtcNow;
    private bool isMouseNearby;
    private bool isCapturingMouse;
    private bool facingRight = true;
    private bool isDragging;
    private Point mouseDownPoint;
    private DispatcherTimer? singleClickTimer;

    public OverlayWindow(
        TaskbarTracker taskbarTracker,
        AppPreferences preferences,
        CatSpriteLibrary spriteLibrary,
        PetStateMachine stateMachine)
    {
        this.taskbarTracker = taskbarTracker;
        this.preferences = preferences;
        this.spriteLibrary = spriteLibrary;
        this.stateMachine = stateMachine;

        InitializeComponent();
        Loaded += OnLoaded;
        MouseDown += OnMouseDown;
        MouseMove += OnMouseMove;
        MouseUp += OnMouseUp;
    }

    public void Calibrate(bool force)
    {
        var layout = taskbarTracker.CurrentLayout();
        if (!force && currentLayout is not null && LayoutEquals(layout, currentLayout))
        {
            return;
        }

        currentLayout = layout;
        Left = layout.ScreenBounds.Left;
        Top = layout.ScreenBounds.Top;
        Width = layout.ScreenBounds.Width;
        Height = layout.ScreenBounds.Height;
        movementController.Configure(layout.Edge, layout.Baseline);

        var sceneSize = new Size(Width, Height);
        if (petPosition == default)
        {
            petPosition = movementController.StartingPosition(sceneSize, petSize);
        }
        else if (force)
        {
            petPosition = movementController.TaskbarAlignedPosition(petPosition, sceneSize, petSize);
        }

        PlacePet();
    }

    public void SetPaused(bool paused)
    {
        stateMachine.SetPaused(paused, Time);
    }

    public void RefreshPreferences()
    {
        preferences.Save();
        PetImage.Width = 160 * preferences.PetScale;
        PetImage.Height = 128 * preferences.PetScale;
        PlacePet();
    }

    private void OnLoaded(object sender, RoutedEventArgs e)
    {
        Calibrate(force: true);
        RefreshPreferences();
        SetClickThrough(true);

        frameTimer.Interval = TimeSpan.FromMilliseconds(33);
        frameTimer.Tick += (_, _) => Tick();
        frameTimer.Start();

        taskbarTimer.Interval = TimeSpan.FromSeconds(2);
        taskbarTimer.Tick += (_, _) => Calibrate(force: false);
        taskbarTimer.Start();
    }

    private void Tick()
    {
        var now = DateTime.UtcNow;
        var delta = Math.Min((now - lastFrameAt).TotalSeconds, 1.0 / 15.0);
        lastFrameAt = now;

        UpdateMouseProximity();
        stateMachine.Update(Time);
        if (isMouseNearby)
        {
            stateMachine.SetWatching(true, Time);
        }

        switch (stateMachine.State)
        {
            case PetState.Walking:
                petPosition = movementController.Update(
                    petPosition,
                    new Size(ActualWidth, ActualHeight),
                    ScaledPetSize,
                    preferences.PetSpeed,
                    delta);
                facingRight = movementController.Direction > 0;
                ApplyAnimation(PetAnimation.Walk);
                break;
            case PetState.Idle:
            case PetState.Looking:
            case PetState.Watching:
                ApplyAnimation(PetAnimation.Idle);
                break;
            case PetState.Sleeping:
                ApplyAnimation(PetAnimation.Sleep);
                break;
            case PetState.Rolling:
                ApplyAnimation(PetAnimation.Stretch);
                break;
            case PetState.Meowing:
                ApplyAnimation(PetAnimation.Meow);
                break;
            case PetState.Paused:
                ApplyAnimation(PetAnimation.Idle);
                break;
        }

        PlacePet();
    }

    private void ApplyAnimation(PetAnimation animation)
    {
        var frames = spriteLibrary.Frames(animation);
        if (frames.Length == 0)
        {
            return;
        }

        var phase = Time % animation.CycleDuration() / animation.CycleDuration();
        var index = Math.Min(frames.Length - 1, (int)(phase * frames.Length));
        PetImage.Source = frames[index];
        MeowText.Visibility = animation == PetAnimation.Meow ? Visibility.Visible : Visibility.Collapsed;
    }

    private void PlacePet()
    {
        var width = PetImage.Width;
        var height = PetImage.Height;
        Canvas.SetLeft(PetImage, petPosition.X - width / 2);
        Canvas.SetTop(PetImage, petPosition.Y - height * 0.9);
        PetImage.RenderTransform = new ScaleTransform(facingRight ? 1 : -1, 1);

        Canvas.SetLeft(MeowText, petPosition.X + (facingRight ? 42 : -68) * preferences.PetScale);
        Canvas.SetTop(MeowText, petPosition.Y - 92 * preferences.PetScale);
    }

    private void UpdateMouseProximity()
    {
        var point = Mouse.GetPosition(this);
        var nearby = InteractionFrame.Contains(point);
        if (nearby && !isDragging)
        {
            facingRight = point.X >= petPosition.X;
        }

        if (nearby != isCapturingMouse)
        {
            isCapturingMouse = nearby;
            SetClickThrough(!nearby);
        }

        isMouseNearby = nearby;
        stateMachine.SetWatching(nearby, Time);
    }

    private void OnMouseDown(object sender, MouseButtonEventArgs e)
    {
        mouseDownPoint = e.GetPosition(this);
        isDragging = false;

        if (e.ClickCount >= 2)
        {
            singleClickTimer?.Stop();
            stateMachine.TriggerSleep(Time);
            e.Handled = true;
            return;
        }

        singleClickTimer?.Stop();
        singleClickTimer = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(220) };
        singleClickTimer.Tick += (_, _) =>
        {
            singleClickTimer?.Stop();
            if (!isDragging)
            {
                stateMachine.TriggerClickReaction(Time);
            }
        };
        singleClickTimer.Start();
    }

    private void OnMouseMove(object sender, MouseEventArgs e)
    {
        if (e.LeftButton != MouseButtonState.Pressed)
        {
            return;
        }

        var point = e.GetPosition(this);
        if (!isDragging && Distance(point, mouseDownPoint) <= 4)
        {
            return;
        }

        isDragging = true;
        singleClickTimer?.Stop();
        petPosition = movementController.SetHomePosition(point, new Size(ActualWidth, ActualHeight), ScaledPetSize);
        facingRight = point.X >= petPosition.X;
        stateMachine.SetWatching(true, Time);
        PlacePet();
    }

    private void OnMouseUp(object sender, MouseButtonEventArgs e)
    {
        isDragging = false;
    }

    private void SetClickThrough(bool clickThrough)
    {
        var handle = new WindowInteropHelper(this).Handle;
        if (handle == IntPtr.Zero)
        {
            return;
        }

        var style = NativeMethods.GetWindowLongPtr(handle, NativeMethods.GWL_EXSTYLE).ToInt64();
        style |= NativeMethods.WS_EX_LAYERED | NativeMethods.WS_EX_TOOLWINDOW | NativeMethods.WS_EX_NOACTIVATE;
        if (clickThrough)
        {
            style |= NativeMethods.WS_EX_TRANSPARENT;
        }
        else
        {
            style &= ~NativeMethods.WS_EX_TRANSPARENT;
        }
        NativeMethods.SetWindowLongPtr(handle, NativeMethods.GWL_EXSTYLE, new IntPtr(style));
    }

    private Rect InteractionFrame => new(
        petPosition.X - ScaledPetSize.Width * 0.62 - 26,
        petPosition.Y - ScaledPetSize.Height * 0.62 - 24,
        ScaledPetSize.Width * 1.24 + 52,
        ScaledPetSize.Height * 1.24 + 48);

    private Size ScaledPetSize => new(petSize.Width * preferences.PetScale, petSize.Height * preferences.PetScale);

    private double Time => (DateTime.UtcNow - startedAt).TotalSeconds;

    private static bool LayoutEquals(TaskbarLayout lhs, TaskbarLayout rhs)
    {
        return lhs.ScreenBounds == rhs.ScreenBounds
            && lhs.TaskbarBounds == rhs.TaskbarBounds
            && lhs.Edge == rhs.Edge
            && Math.Abs(lhs.Baseline - rhs.Baseline) < 1;
    }

    private static double Distance(Point lhs, Point rhs)
    {
        var dx = lhs.X - rhs.X;
        var dy = lhs.Y - rhs.Y;
        return Math.Sqrt(dx * dx + dy * dy);
    }
}
