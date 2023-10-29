# Loki Test App

- Creating a Test App for ["Loki"](https://github.com/grafana/loki).
- Repository Has:
    - Simplest go app you can have.
    - Makefile to configure a ["kind"](https://kind.sigs.k8s.io/) cluster, and deploy the simplest go app there.
    - Makefile configuration to deploy loki, grafana, prometheus and promtail.
    - Run all the "all" target, and the app is running on localhost:8080, and Grafana is running on localhost:3030.

---