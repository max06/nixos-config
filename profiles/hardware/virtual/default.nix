{...}: {
  config = {
    services.openssh.enable = true;

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9ZkPTlFHWEk0uVgGJo7KwYDknYb4je4IPI5QKCU1RR flo.mueller@gec.io"
    ];

    # DO NOT TOUCH
    system.stateVersion = "23.11";
  };
}
