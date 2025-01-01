job "storage-controller-nfs" {
  # https://gitlab.com/rocketduck/csi-plugin-nfs/-/blob/main/nomad/controller.nomad?ref_type=heads
  datacenters = ${datacenters}
  type        = "service"
  namespace   = ${namespace}

  group "controller" {
    task "controller" {
      driver = "podman"

      config {
        image = "registry.gitlab.com/rocketduck/csi-plugin-nfs:0.7.0"

        args = [
          "--type=controller",
          "--node-id=$${attr.unique.hostname}",
          "--nfs-server=${nfs_server}:${nfs_share}", # Adjust accordingly
          "--mount-options=${nfs_mount_opts}", # Adjust accordingly
        ]

        network_mode = "host" # required so the mount works even after stopping the container

        privileged = true
      }

      csi_plugin {
        id        = "rocketduck-nfs" # Whatever you like, but node & controller config needs to match
        type      = "controller"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 500
        memory = 256
      }

    }
  }
}
