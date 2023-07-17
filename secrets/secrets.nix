let
  kelvin_nixia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlD7buD+WXmzv0HW6Ns/LKPbHfqh7Va8JIxNzTY1zsV kelvin@nixia";
  kelvin = [ kelvin_nixia ];
  users = kelvin;

  kazuma = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCd4hv6YZn0Iu6b5rI8vV8PboAg+vUxnFPlvnYj5chEy5n6NmqcAMD0XnDndy+ZlfDIRAYFjp3jd43C63fyGCsBmDKACi608AONnvk3VHX39L/W3sf+7/SPY+B7RrT9Qg9BYyWwQRB3zrM8Mc7BNFzonyhGVHZ5AVAthK2dtFM690GmU6dcGOCKs1UKVfdgiwCmH+lkr94hxjw6wNS0VbdCVbkpYp8SjElU2ndKulQSHzfPwwEB3gRub1uYZyTbljrCN257uH+fVwMiSOlvTTocLjoEdYz9baAeAftsKvYRstFEx811nE26z8oWM+Tv8FX5tIJ5JEzEujvzXrAWrvjN2fAu8z4sbzZJBtorUoOL8ELDdftv7GTalBylgOB1PaAkPwNFV/WcdbO7geLSFSivfPpUCQPEudD3L4CZaqQ+vRY3lJivRfQhBzykV/GsNaWAe1hd+R/mkzLqwHXO5rmuOb8WB1ZEG9OGVWktAN1WDKFk6IaFrYqBzptB2VDfNaxTigaGLjCeyPfeJas/actQj8yaavwtw2vEsG2ys+vD7W+MexMS83SKDRfjlQ48KdNLVR8WQ5sOAR2UEJpR7tvQ5h2ds9j0vcaBnmGEHMv5MEn7NZEKcpbq5O6w9LIuJgnX3Odevv3zO7IeT0i/0OSxnSUClJUpxwQQAk495/kasQ==";
  nixia = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDxYCK5W54iALo12kWvtIGTNg4H/p3+CE9ngZVIF1QntsA6Lh6gFwiglVgV6GyM8ktfx4jWM7hmOlH2ClxLA1m57BVPmUEpGaX5b91LdCmr42Ir5RqHwHjBLRJOpGx0zhQO5iDxD/ozxN9umo+3+fnyQB5ZAk6zh5zAuvrhmqXaDe+lnge2vrB0VYJ6QpSPdZBQ7vzGG0PR5p293yHejAT+KeevbkNNIPbDaX2GpsCfK8u9J+X3Cvo8uEJN/HQaK3t5l2rYeLi65Uuz4R26FYcyRIEoaYuYWhX/vr9ouZkpc+SoPaBoAyMqAEHQHCUegRJ+zgB8G1q0vVrFZYsTSKXBoui/YxNQYdtjw68DDMv5p5ricwhEVAjqHbwIp6li33RcDwoJTPYfoOlK3iLCToJQPHKH+ZNPnUlLN6Rxa8nNFwCbQs7b0cU67QQWPGDquS+kOwL44rYgXZ9dI9EtXHogj1S8KBOFxSUMGV6sbhOStMI8U9sRjqowfdfiqpggOtQl9Hpv+hBnzKtfad4rxBPPh8R/GMK8QYsGOca/1nYEJFBkKUgeUH0bhgPQt5f50PJWfBNYiOVeJtQP2IfC2KHCaArVfpdTm3rl39cgBLuMKDpAb25CRVrIYiPNJFuetyES9HQPuNV6RrK444r+ETGe7sWhe2iqjUcTsYqGEzbi2Q==";
  systems = [ kazuma nixia ];

  stratus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDN73vUDMvgigSgxXsTzM805QLMizJupFnpwFiCelvuf";
  servers = [ stratus ];
in
{
  "duckdns-token-kelvin.age".publicKeys = kelvin ++ systems;
  "dynv6-token-kelvin.age".publicKeys = kelvin ++ systems ++ servers;
}
