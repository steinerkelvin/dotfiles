let
  kelvin_nixia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlD7buD+WXmzv0HW6Ns/LKPbHfqh7Va8JIxNzTY1zsV kelvin@nixia";
  # users = [ kelvin ];

  nixia = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDxYCK5W54iALo12kWvtIGTNg4H/p3+CE9ngZVIF1QntsA6Lh6gFwiglVgV6GyM8ktfx4jWM7hmOlH2ClxLA1m57BVPmUEpGaX5b91LdCmr42Ir5RqHwHjBLRJOpGx0zhQO5iDxD/ozxN9umo+3+fnyQB5ZAk6zh5zAuvrhmqXaDe+lnge2vrB0VYJ6QpSPdZBQ7vzGG0PR5p293yHejAT+KeevbkNNIPbDaX2GpsCfK8u9J+X3Cvo8uEJN/HQaK3t5l2rYeLi65Uuz4R26FYcyRIEoaYuYWhX/vr9ouZkpc+SoPaBoAyMqAEHQHCUegRJ+zgB8G1q0vVrFZYsTSKXBoui/YxNQYdtjw68DDMv5p5ricwhEVAjqHbwIp6li33RcDwoJTPYfoOlK3iLCToJQPHKH+ZNPnUlLN6Rxa8nNFwCbQs7b0cU67QQWPGDquS+kOwL44rYgXZ9dI9EtXHogj1S8KBOFxSUMGV6sbhOStMI8U9sRjqowfdfiqpggOtQl9Hpv+hBnzKtfad4rxBPPh8R/GMK8QYsGOca/1nYEJFBkKUgeUH0bhgPQt5f50PJWfBNYiOVeJtQP2IfC2KHCaArVfpdTm3rl39cgBLuMKDpAb25CRVrIYiPNJFuetyES9HQPuNV6RrK444r+ETGe7sWhe2iqjUcTsYqGEzbi2Q==";
  systems = [ nixia ];
in
{
  "duckdns-token-kelvin.age".publicKeys = [ kelvin_nixia ] ++ systems;
}
