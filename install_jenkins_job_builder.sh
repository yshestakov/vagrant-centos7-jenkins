#!/bin/sh
sudo yum install git gcc make glibc-devel python34 python34-devel python34-pip python-virtualenv libyaml libyaml-devel
git clone https://git.openstack.org/openstack-infra/jenkins-job-builder
cd jenkins-job-buildr
virtualenv -p /usr/bin/python3.4 .venv
source .venv/bin/activate
pip install setuptools --upgrade
pip install Babel
pip install docutils
pip install imagesize
pip install extras
pip install -r requirements.txt
pip install -r test-requirements.txt -e .
# pip install tox
# pip install virtualenv
# tox -e py34
