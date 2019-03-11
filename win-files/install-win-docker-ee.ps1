# On an online machine, download the zip file.
Invoke-WebRequest -UseBasicParsing -OutFile c:\\terraform\\docker-18.09.0.zip https://download.docker.com/components/engine/windows-server/18.09/docker-18.09.0.zip

# Extract the archive.
Expand-Archive c:\\terraform\\docker-18.09.0.zip -DestinationPath $Env:ProgramFiles -Force

# Clean up the zip file.
Remove-Item -Force c:\\terraform\\docker-18.09.0.zip

# Sleep 60 seconds
Start-Sleep -Seconds 60

# Install Docker. This requires rebooting.
$null = Install-WindowsFeature containers


# Add Docker to the path for the current session.
$env:path += ";$env:ProgramFiles\docker"

# Optionally, modify PATH to persist across sessions.
$newPath = "$env:ProgramFiles\docker;" +
[Environment]::GetEnvironmentVariable("PATH",
[EnvironmentVariableTarget]::Machine)

[Environment]::SetEnvironmentVariable("PATH", $newPath,
[EnvironmentVariableTarget]::Machine)

# Register the Docker daemon as a service.
dockerd --register-service

# Must restart the computer
Restart-Computer -Force




