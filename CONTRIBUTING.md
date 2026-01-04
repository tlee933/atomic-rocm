# Contributing to Atomic-ROCm

Thank you for your interest in contributing to Atomic-ROCm! This is a community project and contributions are welcome.

## Ways to Contribute

### 1. Test on Your Hardware

**Most valuable contribution!** Test Atomic-ROCm on your AMD GPU and report results.

**Testing checklist:**
- [ ] Image rebases successfully
- [ ] ROCm tools work (`rocm-smi`, `clinfo`)
- [ ] GPU detected and functional
- [ ] Gaming works (Steam/Proton)
- [ ] AI/ML works (PyTorch in Distrobox)
- [ ] System stable for daily use

**Report results:**
- Open an issue with title: `[Hardware Test] GPU Model`
- Include GPU model, VRAM, architecture (gfx)
- Note what works and what doesn't

### 2. Improve Documentation

**Documentation needs:**
- Clearer installation instructions
- More troubleshooting scenarios
- AI/ML workflow examples
- Gaming setup guides
- Performance benchmarks

**How to contribute:**
- Fork repository
- Edit `README.md` or create new docs
- Submit pull request

### 3. Enhance Containerfile

**Package suggestions:**
- Development tools you use
- Gaming optimizations
- AI/ML packages
- System utilities

**How to contribute:**
- Fork repository
- Edit `Containerfile`
- Test locally with `podman build`
- Submit pull request with explanation

### 4. Report Issues

**Found a bug?** Open an issue!

**Issue template:**
```markdown
### Description
Brief description of the issue

### Steps to Reproduce
1. Step one
2. Step two
3. ...

### Expected Behavior
What should happen

### Actual Behavior
What actually happens

### Environment
- GPU: AMD Radeon ... (gfx...)
- Atomic-ROCm version: (date or commit)
- Fedora version: 40

### Logs
Paste relevant logs here
```

### 5. Submit Pull Requests

**PR Guidelines:**
- One feature/fix per PR
- Test locally before submitting
- Update documentation if needed
- Explain your changes in PR description

## Development Workflow

### Local Testing

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/atomic-rocm.git
cd atomic-rocm

# Make changes to Containerfile
vim Containerfile

# Build locally
podman build -t atomic-rocm:test .

# Test in container
podman run --rm -it atomic-rocm:test bash

# Verify packages installed
rpm -qa | grep rocm
```

### Testing Changes

**Option 1: Container testing (quick)**
```bash
podman run --rm -it atomic-rocm:test bash
# Run commands to verify changes
```

**Option 2: Rebase to local image**
```bash
# Build and tag
podman build -t atomic-rocm:local .

# Push to local registry (optional)
podman tag atomic-rocm:local localhost:5000/atomic-rocm:local

# Rebase
rpm-ostree rebase ostree-unverified-image:containers-storage:atomic-rocm:local

# Reboot
systemctl reboot
```

**Always keep backup deployment for rollback!**

### Commit Messages

**Good commit messages:**
```
Add nvtop for GPU monitoring

- Install nvtop package for real-time GPU stats
- Useful for monitoring VRAM usage during AI workloads
```

**Bad commit messages:**
```
Update Containerfile
```

### Branch Naming

- `feature/feature-name` - New features
- `fix/issue-description` - Bug fixes
- `docs/topic` - Documentation updates

## Code of Conduct

### Be Respectful

- Be kind and patient
- Respect differing viewpoints
- Accept constructive criticism
- Focus on what's best for the community

### Be Collaborative

- Help others learn
- Share knowledge freely
- Credit others' work
- Review PRs thoughtfully

### Be Professional

- Stay on topic
- No harassment or trolling
- Use inclusive language
- Keep it technical

## Questions?

**Not sure about something?**
- Open a discussion on GitHub Discussions
- Ask in an issue (label: `question`)
- Reach out to @tlee933

## Recognition

Contributors will be recognized in:
- GitHub contributors graph
- Release notes (for significant contributions)
- README credits section (for major features)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to Atomic-ROCm!** 🚀
