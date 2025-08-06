# Hashtopolis-Hashcat-Vast Docker Container

**ALWAYS follow these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

This repository creates a Docker container for running Hashtopolis agents on Vast.ai GPU instances, designed for on-demand hash cracking with NVIDIA CUDA support.

## Working Effectively

### Container Build and Deployment
- **NEVER CANCEL**: Docker builds take 5-10 minutes due to CUDA base image download (2.7GB). Set timeout to 15+ minutes minimum.
- Build the Docker image: `docker build -t hashtopolis-hashcat-vast .` -- NEVER CANCEL, expect 5-10 minutes
- Test container functionality: `docker run --rm hashtopolis-hashcat-vast ls /root/htpclient/`
- **Build fails in sandboxed environments** due to network restrictions accessing apt repositories. Document any networking issues when testing.

### Local Development and Testing
Since Docker builds may fail in restricted environments, test hashtopolis agent functionality locally:

1. **Clone and build hashtopolis agent locally**:
   ```bash
   git clone https://github.com/hashtopolis/agent-python.git
   cd agent-python
   ./build.sh
   ```
   Build time: <1 second, creates `hashtopolis.zip`

2. **Install required dependencies**:
   ```bash
   pip3 install psutil requests
   ```

3. **Test agent functionality**:
   ```bash
   python3 hashtopolis.zip --help
   python3 hashtopolis.zip --version
   ```

### Validation Scenarios
Always validate changes using these complete scenarios:

1. **Agent Help Test**: Run `python3 hashtopolis.zip --help` to verify agent loads correctly
2. **Version Check**: Run `python3 hashtopolis.zip --version` to confirm agent version (expect s3-python-0.7.3.x)
3. **Connection Attempt**: Test with invalid server to see expected failure behavior:
   ```bash
   timeout 10s python3 hashtopolis.zip --url http://example.com/api/server.php --voucher test123 --debug
   ```
   Expect: Connection retry attempts and eventual timeout/recursion error

### Testing Infrastructure
- **Test suite requirements**: `pip3 install pytest confidence tuspy py7zr`
- **Run tests**: `python3 -m pytest` (requires running Hashtopolis server with APIv2)
- **Note**: Tests require external Hashtopolis server setup and are not runnable in isolation
- Test files are located in `tests/` directory with various scenarios for hashcat integration

## Key Repository Structure

### Repository Root Files
```
Dockerfile           # NVIDIA CUDA container definition
README.md           # Usage instructions for Vast.ai deployment
renovate.json       # Dependency management configuration
```

### Critical Information

**Build Process**:
- Dockerfile uses `nvidia/cuda:12.9.1-devel-ubuntu20.04` base image
- Installs: zip, git, python3, python3-psutil, python3-requests, pciutils, curl
- Clones hashtopolis agent-python repository
- Builds agent using `./build.sh` script
- Creates final `hashtopolis.zip` executable

**Runtime Environment**:
- Working directory: `/root/htpclient`
- Main executable: `hashtopolis.zip` (Python zip application)
- Required for Vast.ai onstart-script: `python3 hashtopolis.zip --url {server} --voucher {voucher_id}`

**Expected Command Line Usage**:
```bash
python3 hashtopolis.zip --url https://server.com/api/server.php --voucher VOUCHER_CODE
```

### Timing Expectations
- **NEVER CANCEL**: Full Docker build: 5-10 minutes (CUDA base image is 2.7GB)
- Local hashtopolis agent build: <1 second
- Agent dependency install: 1-2 minutes
- Container startup: <10 seconds

### Common Issues and Workarounds
- **Docker build networking failures**: Expected in sandboxed environments, document the limitation
- **Agent connection recursion error**: Normal behavior when server is unreachable
- **CUDA platform errors**: Mentioned in README as expected, should be whitelisted in Hashtopolis server settings
- **Agent trust status**: Requires manual trust or automated cron script as documented in README

### Vast.ai Integration
- Container designed for one-click deployment on Vast.ai GPU instances
- Onstart-script template: `cd htpclient && python3 hashtopolis.zip --url {server} --voucher {voucher_id}`
- Requires reusable voucher codes enabled in Hashtopolis configuration
- Automatically registers agents with Hashtopolis server for hash cracking tasks

### Agent Configuration
- First run creates `config.json` with connection settings
- Supports various options: debug mode, file paths, CPU-only mode, proxy settings
- Compatible with Hashcat versions 4.0.0 through 6.2.6
- Supports generic crackers following Hashtopolis cracker binary requirements

## Development Workflow
1. Always test Docker build process and measure actual timing
2. Validate agent functionality locally when Docker fails
3. Test connection scenarios with debug output
4. Verify agent help and version commands work correctly
5. Document any environment-specific limitations or workarounds

Never assume Docker builds will work in all environments - always provide local testing alternatives.