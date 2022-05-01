ace_trenches
=================

* Adds item `ACE_entrenchingtool`
* Adds 4 trenches: `Envelope - Small`, `Envelope - Big`, `Envelope - Gigant`, `Envelope - Vehicle`
* Adjusts trenches texture based on ground texture

### Whitelist surfaces for digging
Single surfaces can be whitelisted by adding `ACE_canDig = 1` into `CfgSurfaces`.
Example:
```cpp
class CfgSurfaces {
    class myAwesomeSurface {
        ACE_canDig = 1;
    };
};
```

