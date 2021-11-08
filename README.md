# kupi

Ansible playbook to provision K3s on a  raspberry pi cluster. Inspired by [Greg Jeanmart](https://greg.jeanmart.me/2020/04/13/build-your-very-own-self-hosting-platform-wi/).

## Requirements

- At least 2 Raspberry Pis running [Ubuntu](https://ubuntu.com/download/raspberry-pi)
    - If you are in need of an example, [this](#my-hardware) is my hardware setup
    - SSH key for local machine set up across all of the Raspberry Pis

## Running the playbook

```bash
ansible-playbook -i inventory -u ubuntu site.yml -K
```

## My Hardware
- [Raspberry Pi 3 Model B+](https://thepihut.com/products/raspberry-pi-3-model-b-plus) x3
