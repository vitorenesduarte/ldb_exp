# exp 

[![Build Status](https://img.shields.io/travis/vitorenesduarte/exp/master.svg)](https://travis-ci.org/vitorenesduarte/exp)
[![Coverage Status](https://img.shields.io/coveralls/github/vitorenesduarte/exp/master.svg?maxAge=60)](https://coveralls.io/github/vitorenesduarte/exp?branch=master)


#### Experiments

- __LDB_MODE__:
  - `state_based`
  - `delta_based`
  - `pure_op_based`
- __LDB_DRIVEN_MODE__:
  - `none`
  - `state_driven`
  - `digest_driven`
- __LDB_STATE_SYNC_INTERVAL__: milliseconds
- __LDB_REDUNDANT_DGROUPS__: boolean
- __LDB_DGROUP_BACK_PROPAGATION__: boolean
- __OVERLAY__:
  - `hyparview`
  - `fullmesh`
  - `line`
  - `ring`
- __NODE_NUMBER__: number of nodes
- __SIMULATION__:
  - `gcounter`
  - `gset`
  - `awset`
- __NODE_EVENT_NUMBER__: number of events to be performed in
the simulation. The event interval is 1 second
- __GMAP_SIMULATION_KEY_PERCENTAGE__: percentage of keys update at each event in the gmap simulation
- __BREAK_LINKS__:
Links are broken when the simulation
reaches 50% of progress and healed at 75%. Possible values for break link:
  - `none`: no link is broken
  - `one`: a predefined link is broken
  - `half`: 1/2 of the links are broken
  - `quarter`: 1/4 of the links are broken
  - `eighth`: 1/8 of the links are broken


#### Kubernetes

```bash
$ bin/sim.sh build
$ bin/sim.sh
```

- `build` will build a new image, push it, and the run the experiments with that image
- if no argument, the experiments will be run using the last pushed image


#### Google Cloud Platform

- To start and stop the cluster:

```bash
$ bin/g-cluster.sh start
$ bin/g-cluster.sh stop
```

##### Tail the logs

```bash
$ kubectl get pods
              READY     STATUS    RESTARTS   AGE
exp-1488549530072065763-3946360666-0b6d8   0/1       Pending   0
...
$ kubectl logs -f exp-1488549530072065763-3946360666-0b6d8
```


##### lsim dashboard

- To start the dashboard:
```bash
$ bin/lsim-dash-deploy.sh
```

- To open the dashboard:

```bash
$ bin/dash-proxy.sh
```

This will open a new chrome tab with the dashboard.
