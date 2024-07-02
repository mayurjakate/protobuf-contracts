from setuptools import setup
import os

# variables
PACKAGE_NAME = os.getenv('PACKAGE_NAME')
PACKAGE_VERSION = os.getenv('PACKAGE_VERSION')

setup(
    name=PACKAGE_NAME,
    version=PACKAGE_VERSION,
    author="Data Engeneering Team",
    packages=['pytemplate'],
)