## Python venv required.
Ansible deplends on Python to do its thing. Hence, we need top manage our Python environment using a `venv`.

We do not want to check the local libraries into Git for several reasons. We will commit a `requirements.txt`.

## Status
We have successfully refactored our Playbook to use Doppler Secrets.

The Playbook has three dependcies:
  -  Kubernetes Credentials:  `kubectx` must be set for the correct talos cluster,
  -  Doppler:                  Secrets and Access Token for the project and environment,
  -  Python VENV:              A Python VENV must be activated and have proper libraries loaded.

