using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using PetCompanion.Windows.Pet;

namespace PetCompanion.Windows.Platform;

public sealed class TrayController : IDisposable
{
    private readonly AppPreferences preferences;
    private readonly Action onTogglePause;
    private readonly Action onCalibrate;
    private readonly Action onOpenPreferences;
    private readonly Action onExit;
    private NotifyIcon? notifyIcon;

    public TrayController(
        AppPreferences preferences,
        Action onTogglePause,
        Action onCalibrate,
        Action onOpenPreferences,
        Action onExit)
    {
        this.preferences = preferences;
        this.onTogglePause = onTogglePause;
        this.onCalibrate = onCalibrate;
        this.onOpenPreferences = onOpenPreferences;
        this.onExit = onExit;
    }

    public void Install()
    {
        notifyIcon = new NotifyIcon
        {
            Text = "萌宠陪伴",
            Icon = LoadIcon(),
            Visible = true
        };
        Refresh();
    }

    public void Refresh()
    {
        if (notifyIcon is null)
        {
            return;
        }

        var menu = new ContextMenuStrip();
        menu.Items.Add(preferences.IsPaused ? "恢复小猫" : "暂停小猫", null, (_, _) => onTogglePause());
        menu.Items.Add("立即校准任务栏", null, (_, _) => onCalibrate());
        menu.Items.Add("设置...", null, (_, _) => onOpenPreferences());
        menu.Items.Add(new ToolStripSeparator());
        menu.Items.Add("退出萌宠陪伴", null, (_, _) => onExit());
        notifyIcon.ContextMenuStrip = menu;
    }

    public void Dispose()
    {
        if (notifyIcon is not null)
        {
            notifyIcon.Visible = false;
            notifyIcon.Dispose();
            notifyIcon = null;
        }
    }

    private static Icon LoadIcon()
    {
        var iconPath = Path.Combine(AppContext.BaseDirectory, "app.ico");
        return File.Exists(iconPath) ? new Icon(iconPath) : SystemIcons.Application;
    }

}
