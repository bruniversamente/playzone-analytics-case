$patterns = @(
  "sk_",
  "pk_live",
  "AIza",
  "mongodb\+srv",
  "bearer\s+",
  "authorization:\s*bearer",
  "password",
  "secret",
  "apikey",
  "private_key",
  "BEGIN PRIVATE KEY"
)

Get-ChildItem -Recurse -File | Select-String -Pattern $patterns -CaseSensitive:$false