using System;
using System.IO;
using System.Text.Json;

namespace PetCompanion.Windows.Pet;

public sealed class AppPreferences
{
    private static readonly string DirectoryPath = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
        "PetCompanion");
    private static readonly string FilePath = Path.Combine(DirectoryPath, "preferences.json");

    public bool IsPaused { get; set; }
    public double PetSpeed { get; set; } = 82;
    public double PetScale { get; set; } = 1;
    public bool ShowInFullScreen { get; set; }
    public bool LaunchAtLogin { get; set; }

    public AppPreferences()
    {
        Load();
    }

    public void Save()
    {
        Directory.CreateDirectory(DirectoryPath);
        var data = new PreferenceData(IsPaused, PetSpeed, PetScale, ShowInFullScreen, LaunchAtLogin);
        var json = JsonSerializer.Serialize(data, new JsonSerializerOptions { WriteIndented = true });
        File.WriteAllText(FilePath, json);
    }

    private void Load()
    {
        if (!File.Exists(FilePath))
        {
            return;
        }

        try
        {
            var loaded = JsonSerializer.Deserialize<PreferenceData>(File.ReadAllText(FilePath));
            if (loaded is null)
            {
                return;
            }

            IsPaused = loaded.IsPaused;
            PetSpeed = loaded.PetSpeed;
            PetScale = loaded.PetScale;
            ShowInFullScreen = loaded.ShowInFullScreen;
            LaunchAtLogin = loaded.LaunchAtLogin;
        }
        catch
        {
            // Keep defaults when the user config is unreadable.
        }
    }

    private sealed record PreferenceData(
        bool IsPaused,
        double PetSpeed,
        double PetScale,
        bool ShowInFullScreen,
        bool LaunchAtLogin);
}
