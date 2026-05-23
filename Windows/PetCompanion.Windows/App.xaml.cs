using System.Windows;
using PetCompanion.Windows.Pet;
using PetCompanion.Windows.Platform;
using PetCompanion.Windows.UI;

namespace PetCompanion.Windows;

public partial class App : Application
{
    private readonly AppPreferences preferences = new();
    private OverlayWindow? overlayWindow;
    private TrayController? trayController;
    private PreferencesWindow? preferencesWindow;

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        var taskbarTracker = new TaskbarTracker();
        var spriteLibrary = new CatSpriteLibrary();
        var stateMachine = new PetStateMachine();

        overlayWindow = new OverlayWindow(taskbarTracker, preferences, spriteLibrary, stateMachine);
        overlayWindow.Show();

        trayController = new TrayController(
            preferences,
            onTogglePause: TogglePause,
            onCalibrate: () => overlayWindow.Calibrate(force: true),
            onOpenPreferences: OpenPreferences,
            onExit: Shutdown);
        trayController.Install();
    }

    protected override void OnExit(ExitEventArgs e)
    {
        trayController?.Dispose();
        overlayWindow?.Close();
        base.OnExit(e);
    }

    private void TogglePause()
    {
        preferences.IsPaused = !preferences.IsPaused;
        overlayWindow?.SetPaused(preferences.IsPaused);
        trayController?.Refresh();
    }

    private void OpenPreferences()
    {
        preferencesWindow ??= new PreferencesWindow(preferences, () => overlayWindow?.RefreshPreferences());
        preferencesWindow.RefreshControls();
        preferencesWindow.Show();
        preferencesWindow.Activate();
    }
}
