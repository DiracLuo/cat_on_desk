using System;
using System.Windows;
using PetCompanion.Windows.Pet;
using PetCompanion.Windows.Platform;

namespace PetCompanion.Windows.UI;

public partial class PreferencesWindow : Window
{
    private readonly AppPreferences preferences;
    private readonly Action onChange;
    private readonly LoginItemController loginItemController = new();
    private bool isRefreshing;

    public PreferencesWindow(AppPreferences preferences, Action onChange)
    {
        this.preferences = preferences;
        this.onChange = onChange;
        InitializeComponent();
        Closing += (_, e) =>
        {
            e.Cancel = true;
            Hide();
        };
        RefreshControls();
    }

    public void RefreshControls()
    {
        isRefreshing = true;
        SpeedSlider.Value = preferences.PetSpeed;
        ScaleSlider.Value = preferences.PetScale;
        FullScreenCheckBox.IsChecked = preferences.ShowInFullScreen;
        LaunchAtLoginCheckBox.IsChecked = loginItemController.IsEnabled();
        SpeedLabel.Text = $"{preferences.PetSpeed:0} px/s";
        ScaleLabel.Text = $"{preferences.PetScale * 100:0}%";
        LoginStatusLabel.Text = loginItemController.IsEnabled() ? "登录项状态：已开启" : "登录项状态：未开启";
        isRefreshing = false;
    }

    private void OnSpeedChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
    {
        if (isRefreshing)
        {
            return;
        }

        preferences.PetSpeed = e.NewValue;
        preferences.Save();
        RefreshControls();
        onChange();
    }

    private void OnScaleChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
    {
        if (isRefreshing)
        {
            return;
        }

        preferences.PetScale = e.NewValue;
        preferences.Save();
        RefreshControls();
        onChange();
    }

    private void OnFullScreenChanged(object sender, RoutedEventArgs e)
    {
        if (isRefreshing)
        {
            return;
        }

        preferences.ShowInFullScreen = FullScreenCheckBox.IsChecked == true;
        preferences.Save();
        onChange();
    }

    private void OnLaunchAtLoginChanged(object sender, RoutedEventArgs e)
    {
        if (isRefreshing)
        {
            return;
        }

        try
        {
            loginItemController.SetEnabled(LaunchAtLoginCheckBox.IsChecked == true);
            preferences.LaunchAtLogin = LaunchAtLoginCheckBox.IsChecked == true;
            preferences.Save();
        }
        catch (Exception error)
        {
            LoginStatusLabel.Text = $"登录项更新失败：{error.Message}";
            return;
        }

        RefreshControls();
    }
}
