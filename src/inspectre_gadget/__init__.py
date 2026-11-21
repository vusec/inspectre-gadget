"""InSpectre Gadget: a tool for inspecting Spectre disclosure gadgets."""

from importlib.metadata import PackageNotFoundError, version

try:
    __version__ = version("inspectre-gadget")
except PackageNotFoundError:  # running from a source tree without installing
    __version__ = "0.0.0"
