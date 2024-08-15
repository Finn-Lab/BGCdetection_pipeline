from setuptools import setup, find_packages

setup(
    name='BGCdetection_pipeline',
    version='0.1.0',
    packages=find_packages(),
    install_requires=[
        'biopython',
        'nextflow',
        # 'singularity',
    ],
    entry_points={
        'console_scripts': [
        ],
    },

    include_package_data=True,
    author='Santiago Sanchez',
    author_email='fragoso@ebi.ac.uk',
    description='Module for Extract BGC data from cold storage filesystem EMBL-EBI',
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    url='https://github.com/Finn-Lab/BGCdetection_pipeline',
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],
    python_requires='>=3.9',
)
