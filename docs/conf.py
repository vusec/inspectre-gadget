# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information
import os
import sys
sys.path.insert(0, os.path.abspath('../'))  # Source code dir relative to this file


project = 'InSpectre Gadget'
copyright = '2023, Sander Wiebing & Alvise de Faveri Tron - Vrije Universiteit Amsterdam'
author = 'Sander Wiebing & Alvise de Faveri Tron - Vrije Universiteit Amsterdam'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ['myst_parser', 'sphinx.ext.autodoc', 'sphinx.ext.autosummary']
autosummary_generate = True  # Turn on sphinx.ext.autosummary

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']


# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'alabaster'
html_static_path = ['_static', 'img']

logo_url = "img/inspectre-gadget2.jpeg"

html_sidebars = {
        '**': [
                 'icon.html',
                #  'about.html',
                 'navigation.html',
                 'searchbox.html',
            ]

        }

