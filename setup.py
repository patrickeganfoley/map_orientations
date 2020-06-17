from setuptools import setup, find_packages

setup(
    name="maps",
    version="0.2.0",
    description="A few scripts to make cool maps",
    url="http://github.com/patrickeganfoley/map_projections",
    author="Patrick Foley",
    author_email="patrick.egan.foley@gmail.com",
    packages=find_packages(),
    install_requires=[
        'imageio',
        'jupyter',
        'matplotlib',
        'numpy',
        'imageio'
    ]
)
