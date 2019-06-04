"""
This is the setup module for the Gophish initilization project.

Based on:

- https://packaging.python.org/distributing/
- https://github.com/pypa/sampleproject/blob/master/setup.py
- https://blog.ionelmc.ro/2014/05/25/python-packaging/#the-structure
"""

from glob import glob
from os.path import splitext, basename

from setuptools import setup, find_packages


def readme():
    """Read in and return the contents of the project's README.md file."""
    with open("README.md") as f:
        return f.read()


def package_vars(version_file):
    """Read in and return the variables defined by the version_file."""
    pkg_vars = {}
    with open(version_file) as f:
        exec(f.read(), pkg_vars)  # nosec
    return pkg_vars


# these requirements are missing from the gophish-0.2.5 install_requires
# these extras will be required until the following PR is merged:
# https://github.com/gophish/api-client-python/pull/16
gophish_missing_requirements = [
    "appdirs==1.4.0",
    "packaging==16.8",
    "pyparsing==2.1.10",
    "python-dateutil==2.6.0",
    "requests>=2.20.0",
    "six==1.10.0",
]

setup(
    name="gophish_init",
    # Versions should comply with PEP440
    version=package_vars("src/gophish_init/_version.py")["__version__"],
    description="Gophish initilization library",
    long_description=readme(),
    long_description_content_type="text/markdown",
    # NCATS "homepage"
    url="https://www.us-cert.gov/resources/ncats",
    # The project's main homepage
    download_url="https://github.com/cisagov/skeleton-python-library",  # TODO
    # Author details
    author="Cyber and Infrastructure Security Agency",
    author_email="ncats@hq.dhs.gov",
    license="License :: CC0 1.0 Universal (CC0 1.0) Public Domain Dedication",
    # See https://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=[
        # How mature is this project? Common values are
        #   3 - Alpha
        #   4 - Beta
        #   5 - Production/Stable
        "Development Status :: 3 - Alpha",
        # Indicate who your project is intended for
        "Intended Audience :: Developers",
        # Pick your license as you wish (should match "license" above)
        "License :: CC0 1.0 Universal (CC0 1.0) Public Domain Dedication",
        # Specify the Python versions you support here. In particular, ensure
        # that you indicate whether you support Python 2, Python 3 or both.
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
    ],
    # What does your project relate to?
    keywords="gophish_init",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    py_modules=[splitext(basename(path))[0] for path in glob("src/*.py")],
    include_package_data=True,
    install_requires=["docopt", "gophish"] + gophish_missing_requirements,
    extras_require={"test": ["pre-commit", "pytest", "pytest-cov", "coveralls"]},
    # Conveniently allows one to run the CLI tool as `example`
    entry_points={"console_scripts": ["gophish-init = gophish_init.gophish_init:main"]},
)
