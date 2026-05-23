namespace PetCompanion.Windows.Pet;

public enum PetState
{
    Walking,
    Idle,
    Looking,
    Watching,
    Sleeping,
    Rolling,
    Meowing,
    Paused
}

public sealed class PetStateMachine
{
    private readonly Random random = new();
    private PetState previousActiveState = PetState.Walking;
    private double nextTransitionAt = 6;

    public PetState State { get; private set; } = PetState.Walking;
    public bool IsPaused => State == PetState.Paused;
    public bool IsSleeping => State == PetState.Sleeping;

    public void SetPaused(bool paused, double time)
    {
        if (paused)
        {
            if (State != PetState.Paused)
            {
                previousActiveState = State;
                TransitionTo(PetState.Paused, time);
            }
        }
        else if (State == PetState.Paused)
        {
            TransitionTo(previousActiveState, time);
        }
    }

    public void Update(double time)
    {
        if (State == PetState.Paused || time < nextTransitionAt)
        {
            return;
        }

        switch (State)
        {
            case PetState.Walking:
                TransitionTo(PetState.Idle, time);
                break;
            case PetState.Idle:
                TransitionTo(NextIdleTransition(), time);
                break;
            case PetState.Looking:
            case PetState.Sleeping:
            case PetState.Rolling:
            case PetState.Meowing:
                TransitionTo(PetState.Walking, time);
                break;
            case PetState.Watching:
                nextTransitionAt = double.PositiveInfinity;
                break;
        }
    }

    public void SetWatching(bool watching, double time)
    {
        if (State == PetState.Paused)
        {
            return;
        }

        if (watching)
        {
            if (State is PetState.Walking or PetState.Idle or PetState.Looking)
            {
                TransitionTo(PetState.Watching, time);
            }
        }
        else if (State == PetState.Watching)
        {
            TransitionTo(PetState.Walking, time);
        }
    }

    public void TriggerClickReaction(double time)
    {
        if (State == PetState.Paused)
        {
            return;
        }

        TransitionTo(random.NextDouble() < 0.5 ? PetState.Meowing : PetState.Rolling, time);
    }

    public void TriggerSleep(double time)
    {
        if (State == PetState.Paused)
        {
            return;
        }

        TransitionTo(State == PetState.Sleeping ? PetState.Walking : PetState.Sleeping, time);
    }

    private PetState NextIdleTransition()
    {
        var roll = random.NextDouble();
        if (roll < 0.20)
        {
            return PetState.Looking;
        }
        if (roll < 0.38)
        {
            return PetState.Sleeping;
        }
        if (roll < 0.56)
        {
            return PetState.Rolling;
        }
        if (roll < 0.72)
        {
            return PetState.Meowing;
        }
        return PetState.Walking;
    }

    private void TransitionTo(PetState state, double time)
    {
        State = state;
        nextTransitionAt = state switch
        {
            PetState.Walking => time + RandomRange(4, 9),
            PetState.Idle => time + RandomRange(1.5, 4),
            PetState.Looking => time + RandomRange(2, 4),
            PetState.Watching => double.PositiveInfinity,
            PetState.Sleeping => time + RandomRange(7, 14),
            PetState.Rolling => time + 2.4,
            PetState.Meowing => time + 2.0,
            PetState.Paused => double.PositiveInfinity,
            _ => time + 3
        };
    }

    private double RandomRange(double min, double max) => min + random.NextDouble() * (max - min);
}
