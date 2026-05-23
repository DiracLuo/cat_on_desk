using System;
using System.Collections.Generic;
using System.IO;
using System.Windows.Media.Imaging;

namespace PetCompanion.Windows.Pet;

public sealed class CatSpriteLibrary
{
    private readonly Dictionary<PetAnimation, BitmapImage[]> cache = new();

    public BitmapImage[] Frames(PetAnimation animation)
    {
        if (cache.TryGetValue(animation, out var frames))
        {
            return frames;
        }

        var list = new List<BitmapImage>();
        var assetDir = Path.Combine(AppContext.BaseDirectory, "Assets", "CatSprites");
        for (var index = 0; index < animation.FrameCount(); index++)
        {
            var path = Path.Combine(assetDir, $"{animation.Prefix()}_{index:00}.png");
            if (!File.Exists(path))
            {
                continue;
            }

            var image = new BitmapImage();
            image.BeginInit();
            image.CacheOption = BitmapCacheOption.OnLoad;
            image.UriSource = new Uri(path, UriKind.Absolute);
            image.EndInit();
            image.Freeze();
            list.Add(image);
        }

        frames = list.ToArray();
        cache[animation] = frames;
        return frames;
    }
}
