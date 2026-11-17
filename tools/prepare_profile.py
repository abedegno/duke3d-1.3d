"""Expose the project's tracked profile inside its pinned Exhume dependency."""
from pathlib import Path


def prepare_profile(root: Path) -> None:
    source=root/'profiles/watcom'
    destination=root/'exhume/profiles/watcom'
    if not source.is_dir() or not destination.parent.is_dir():
        raise FileNotFoundError('Initialize Exhume and the tracked Watcom overlay first')
    if destination.is_symlink() and destination.resolve()==source.resolve():
        return
    if destination.exists() or destination.is_symlink():
        raise FileExistsError(f'Refusing to replace existing profile: {destination}')
    destination.symlink_to('../../profiles/watcom',target_is_directory=True)


if __name__=='__main__':
    prepare_profile(Path(__file__).resolve().parents[1])
