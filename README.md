# Jupyter Docker Base Stack with compatibility for SQL Server

This image provides an abstract Jupyter Docker Stack base for Python developers with SQL Server compatibility on Linux.

## Dockerfile

The following components are included:

- Ubuntu 18.04 OS layer.
- Install all OS dependencies for notebook server.
- Modifications to the [Base Jupyter Docker Stack](https://github.com/jupyter/docker-stacks/tree/master/base-notebook) for compatibility with the SQL Server driver for Linux.

> This is an abstract image. It is not very useful to create containers from it. It is only taken as the base image for the most complete images of Jupyter.
