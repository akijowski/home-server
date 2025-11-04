# NixOS Flakes for DevBox

Creating a stable python development environmet became a bit of a challenge.
I am leveraging NixOS flake support in devbox to define the ansible + python tools needed.

I just made the simplest flake I could, using `withPackages` to define the python environment.

## Links

- https://github.com/jetify-com/devbox/tree/main/examples/flakes
- Does work, just over kill: https://pyproject-nix.github.io/pyproject.nix/use-cases/pyproject.html
- https://www.thenegation.com/posts/nix-powered-python-dev/
