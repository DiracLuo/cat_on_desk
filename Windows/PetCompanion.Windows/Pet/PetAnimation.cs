namespace PetCompanion.Windows.Pet;

public enum PetAnimation
{
    Walk,
    Idle,
    Sleep,
    Stretch,
    Meow
}

public static class PetAnimationExtensions
{
    public static string Prefix(this PetAnimation animation) => animation switch
    {
        PetAnimation.Walk => "walk",
        PetAnimation.Idle => "idle",
        PetAnimation.Sleep => "sleep",
        PetAnimation.Stretch => "stretch",
        PetAnimation.Meow => "meow",
        _ => "idle"
    };

    public static int FrameCount(this PetAnimation animation) => animation switch
    {
        PetAnimation.Walk => 4,
        PetAnimation.Idle => 3,
        PetAnimation.Sleep => 4,
        PetAnimation.Stretch => 4,
        PetAnimation.Meow => 4,
        _ => 1
    };

    public static double CycleDuration(this PetAnimation animation) => animation switch
    {
        PetAnimation.Walk => 0.72,
        PetAnimation.Idle => 2.4,
        PetAnimation.Sleep => 2.8,
        PetAnimation.Stretch => 2.4,
        PetAnimation.Meow => 1.0,
        _ => 1.0
    };
}
