#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine OS and Arch
OS=$(uname -s)
ARCH=$(uname -m)

echo -e "${BLUE}🚀 Starting Monty Build for Mac M1 Pro and Ampere (Linux ARM64)...${NC}"

# Navigate to the correct directory
cd crates/monty-python

# 1. Build Native Mac Wheel (Optional if you only need Linux for Coolify)
echo -e "${GREEN}🍎 Building native macOS ARM64 wheel...${NC}"
uvx maturin build --release --out ../../target/wheels

# 2. Build Linux ARM64 Wheel (for Ampere/Coolify)
echo -e "${GREEN}🐧 Building Linux ARM64 wheel using Docker...${NC}"
echo -e "${BLUE}💡 Note: If this fails with SIGKILL, please increase Docker Desktop memory (8GB+ recommended).${NC}"

# We mount the workspace root to /io
# We limit parallel jobs to 2 (CARGO_BUILD_JOBS) to avoid Out-Of-Memory (OOM) on Docker
# We specify -i python3.13 to ensure the wheel matches SynapseOS Python version
docker run --rm -v $(cd ../.. && pwd):/io \
  -e CARGO_BUILD_JOBS=2 \
  ghcr.io/pyo3/maturin build --release --target aarch64-unknown-linux-gnu --out target/wheels -m crates/monty-python/Cargo.toml -i python3.13

echo -e "${BLUE}✅ Build complete! Wheels are located in:${NC}"
echo -e "   - Linux ARM64 (for SynapseOS): monty/target/wheels/pydantic_monty-*-cp313-cp313-manylinux_*.whl"

echo -e "${BLUE}Next Steps:${NC}"
echo -e "1. Create a GitHub Release in titi008/monty"
echo -e "2. Upload the Linux cp313 wheel from target/wheels/"
echo -e "3. Update SynapseOS pyproject.toml with the Release URL"
